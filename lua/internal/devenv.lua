--- Keep nvim's environment in sync with devenv.
---
--- devenv has no socket to subscribe to: its own hot reload lives inside the
--- `devenv shell` process. What it does leave behind is
--- `$DEVENV_DOTFILE/gc/shell`, a GC-root symlink into the nix store that is
--- re-pointed on every successful build. That symlink is the signal: watch
--- it, and when its target moves (someone ran `devenv shell`, `devenv up`,
--- direnv reloaded) re-export.
---
--- Not `$DEVENV_PROFILE` / `.devenv/profile`, tempting as the name is: the
--- profile is only the realised *package set*, so editing `env`, `scripts` or
--- `enterShell` rebuilds the shell while the profile path stays byte for byte
--- identical. It is a fine marker for "packages changed" and a silent liar
--- for everything else.
---
--- Writes to `devenv.nix` are deliberately not a trigger. A write on its own
--- changes nothing -- the shell only moves once something actually builds --
--- and exporting on write would mean nvim does the rebuild and then sees its
--- own swap come back through the watcher.
---
--- ```lua
--- require("internal.devenv"):reload()          -- force a re-export
--- require("internal.devenv"):check()           -- re-export, apply only on change
--- require("internal.devenv"):watch(dir)        -- follow a project's shell
--- ```
---@class Devenv
---@field refresh boolean export in flight
---@field shell? string store path of the generation currently in `vim.env`
---@field applied table<string, true> keys this module exported, for removal
local Devenv = {
	refresh = false,
	applied = {},
}

--- Variables that are per-process or per-build noise: adopting them would
--- break nvim (VIM*), point at garbage-collectable build dirs (TMP*,
--- NIX_BUILD_TOP) or lie about where we are (PWD).
local VOLATILE = {
	_ = true,
	NIX_BUILD_TOP = true,
	OLDPWD = true,
	PWD = true,
	SHLVL = true,
	TEMP = true,
	TEMPDIR = true,
	TMP = true,
	TMPDIR = true,
	MYVIMRC = true,
	NVIM = true,
	NVIM_APPNAME = true,
	NVIM_LOG_FILE = true,
	VIM = true,
	VIMRUNTIME = true,
}

--- `PATH`-like lists are prepended, never replaced: the devenv profile must
--- win, but nvim's own wrapper entries (nixCats packpath helpers, user bins)
--- have to survive the swap.
local MERGED = { PATH = true, XDG_DATA_DIRS = true, MANPATH = true, INFOPATH = true }

--- Coalesce the burst of events one rebuild produces into a single check.
local DEBOUNCE = 200

--- Live watchers, keyed by project dir, so repeated `:watch()` is a no-op.
---@type table<string, { event: uv.uv_fs_event_t, timer: uv.uv_timer_t }>
local watchers = {}

--- The GC root is replaced rather than edited, so the watch has to sit on
--- the containing directory -- which also holds the task-config root, rewritten
--- on unrelated runs. Hence: readlink first, spawn only on a real move.
---@param dir string
---@return string? target store path, nil when the project was never built
local function shell_of(dir)
	return vim.uv.fs_readlink(dir .. "/.devenv/gc/shell")
end

--- Prepend `new` to `old`, dropping duplicates and trailing slashes.
---@param new string
---@param old? string
---@return string
local function merge_list(new, old)
	local seen, out = {}, {}
	for _, entry in ipairs(vim.split(new .. (old and old ~= "" and ":" .. old or ""), ":", { plain = true })) do
		entry = entry:gsub("/+$", "")
		if entry ~= "" and not seen[entry] then
			seen[entry] = true
			out[#out + 1] = entry
		end
	end
	return table.concat(out, ":")
end

--- Parse `env -0` output into a table.
---@param stdout string
---@return table<string, string>
local function parse_env(stdout)
	local env = {}
	for entry in vim.gsplit(stdout, "\0", { plain = true }) do
		local key, value = entry:match("^([^=]+)=(.*)$")
		if key then
			env[key] = value
		end
	end
	return env
end

--- Apply an exported environment to this process.
---@param env table<string, string>
---@param shell? string generation this environment came from
function Devenv:apply(env, shell)
	local applied = {}
	for key, value in pairs(env) do
		if not VOLATILE[key] then
			applied[key] = true
			if MERGED[key] then
				vim.env[key] = merge_list(value, vim.env[key])
			else
				vim.env[key] = value
			end
		end
	end

	-- variables the previous generation exported and this one dropped
	for key in pairs(self.applied) do
		if not applied[key] and not MERGED[key] then
			vim.env[key] = nil
		end
	end

	self.applied = applied
	self.shell = shell
end

--- Re-export the environment of `dir` (defaults to the cwd) into nvim.
---
--- Asynchronous: pass `on_done` to run work that must see the new
--- environment. It is always invoked, with `false` when nothing was applied
--- (export in flight, devenv missing or not a devenv project, build failed,
--- or `opts.changed_only` and the generation is unchanged).
---@param dir? string
---@param opts? { changed_only?: boolean, on_done?: fun(applied: boolean) }
function Devenv:reload(dir, opts)
	opts = opts or {}
	local progress ---@type internal.Progress|nil

	local function done(applied)
		if progress then
			progress:finish({ message = applied and "done" or "failed" })
			progress = nil
		end
		if opts.on_done then
			vim.schedule(function()
				opts.on_done(applied)
			end)
		end
	end

	if self.refresh then
		done(false)
		return
	end

	dir = dir or vim.uv.cwd() or vim.fn.getcwd()
	if not vim.uv.fs_stat(dir .. "/devenv.nix") then
		done(false)
		return
	end

	-- the generation marker lives on disk, not in the exported environment,
	-- so "has anything changed" is answered by a readlink, before any spawn
	if opts.changed_only and shell_of(dir) == self.shell then
		done(false)
		return
	end
	self.refresh = true

	-- nix evals can take a while: show an LSP-init style spinner
	progress = require("internal.ui.progress").start({
		client = "devenv",
		title = "shell",
		message = vim.fn.fnamemodify(dir, ":~"),
	})

	-- `devenv shell -- env -0` is cheap on a warm eval cache (content-hashed,
	-- no nix invocation at all when nothing changed)
	local spawned = pcall(
		vim.system,
		{ "devenv", "shell", "--", "env", "-0" },
		{ cwd = dir, env = { DEVENV_TUI = "false", DEVENV_NO_AI_AGENT = "1" } },
		function(out)
			self.refresh = false
			if out.code ~= 0 or not out.stdout or out.stdout == "" then
				done(false)
				return
			end

			local env = parse_env(out.stdout)
			if vim.tbl_isempty(env) then
				done(false)
				return
			end

			-- re-read: this export may itself have built a newer generation
			local shell = shell_of(dir)
			vim.schedule(function()
				self:apply(env, shell)
				done(true)
			end)
		end
	)

	if not spawned then
		-- devenv is not installed / not executable
		self.refresh = false
		done(false)
	end
end

--- Re-export, but only touch the environment when the shell store path
--- actually moved (i.e. the project was rebuilt).
---@param dir? string
---@param on_done? fun(applied: boolean)
function Devenv:check(dir, on_done)
	self:reload(dir, { changed_only = true, on_done = on_done })
end

--- Follow `dir`'s shell GC root and re-export whenever it moves.
---
--- Also reconciles once up front: the generation may have moved while nvim
--- was not watching (started outside the shell, rebuilt from another
--- terminal). Nothing happens for a project that was never built -- there is
--- no `.devenv/gc` to watch, and the next `watch()` picks it up once there is.
---@param dir? string
function Devenv:watch(dir)
	dir = dir or vim.uv.cwd() or vim.fn.getcwd()
	if watchers[dir] then
		return
	end

	local shell = shell_of(dir)
	if not shell then
		return
	end

	-- nvim launched from inside this project's shell already carries this
	-- generation; adopting it silently avoids a pointless export at startup
	if not self.shell and vim.env.DEVENV_ROOT == dir then
		self.shell = shell
	end
	if shell ~= self.shell then
		self:check(dir)
	end

	local event, timer = vim.uv.new_fs_event(), vim.uv.new_timer()
	if not event or not timer then
		return
	end

	local ok = event:start(dir .. "/.devenv/gc", {}, function(err, name)
		-- the dir also holds the task-config root, rewritten on unrelated runs
		if err or (name and name ~= "shell") then
			return
		end
		-- a rebuild touches the dir many times; settle, then compare
		timer:start(DEBOUNCE, 0, function()
			local target = shell_of(dir)
			if not target or target == Devenv.shell then
				return
			end
			vim.schedule(function()
				Devenv:check(dir)
			end)
		end)
	end)

	if not ok then
		event:close()
		timer:close()
		return
	end
	watchers[dir] = { event = event, timer = timer }
end

--- Drop every watcher (`dir`'s only, when given).
---@param dir? string
function Devenv:unwatch(dir)
	for key, watcher in pairs(watchers) do
		if not dir or key == dir then
			watcher.event:stop()
			watcher.timer:stop()
			if not watcher.event:is_closing() then
				watcher.event:close()
			end
			if not watcher.timer:is_closing() then
				watcher.timer:close()
			end
			watchers[key] = nil
		end
	end
end

local group = vim.api.nvim_create_augroup("Devenv", { clear = true })

-- a new cwd may be a devenv project of its own; watchers are additive so
-- buffers left behind in the old tree keep their environment followed
vim.api.nvim_create_autocmd("DirChanged", {
	group = group,
	callback = function()
		Devenv:watch()
	end,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
	group = group,
	callback = function()
		Devenv:unwatch()
	end,
})

Devenv:watch()

vim.api.nvim_create_user_command("DevenvReload", function()
	Devenv:reload()
end, { desc = "Re-export the devenv environment into nvim" })

return Devenv
