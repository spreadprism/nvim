---@enum EnvrcStatus
local EnvrcStatus = {
	ALLOWED = 0,
	UNSET = 1,
	DENIED = 2,
}

---@class Direnv
---@field refresh boolean
---@field envrc table<string, EnvrcStatus>
local Direnv = {
	refresh = false,
	envrc = {},
}

local group = vim.api.nvim_create_augroup("Direnv", { clear = true })

--- Files whose contents feed the environment: the .envrc itself and any dotenv
--- file it may source (`dotenv`/`dotenv_if_exists` in direnv stdlib).
---@param basename string
---@return boolean
local function is_env_file(basename)
	return basename == ".envrc" or basename == ".env" or vim.startswith(basename, ".env.")
end

vim.api.nvim_create_autocmd("BufEnter", {
	group = group,
	callback = function(args)
		local path = vim.api.nvim_buf_get_name(args.buf)
		local basename = vim.fs.basename(path)
		if basename == ".envrc" then
			Direnv:status(path)
		end
	end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
	group = group,
	callback = function(args)
		if vim.bo.ft == "oil" then
			return
		end
		local path = vim.api.nvim_buf_get_name(args.buf)
		local basename = vim.fs.basename(path)
		-- only these writes can change the environment
		if not is_env_file(basename) then
			return
		end

		-- editing an .envrc invalidates its trust hash, re-allow when it was
		-- already allowed before the write
		if basename == ".envrc" and Direnv.envrc[path] == EnvrcStatus.ALLOWED then
			Direnv:allow()
		end
		Direnv:reload()
	end,
})

function Direnv:allow()
	local path = vim.api.nvim_buf_get_name(0)
	local basename = vim.fs.basename(path)

	if basename ~= ".envrc" then
		return
	end

	local dir = vim.fs.dirname(path)

	self.envrc[path] = EnvrcStatus.ALLOWED
	vim.system({ "direnv", "allow" }, { cwd = dir }):wait()
end

function Direnv:deny()
	local path = vim.api.nvim_buf_get_name(0)
	local basename = vim.fs.basename(path)

	if basename ~= ".envrc" then
		return
	end

	local dir = vim.fs.dirname(path)
	self.envrc[path] = EnvrcStatus.DENIED
	vim.system({ "direnv", "deny" }, { cwd = dir }):wait()
end

--- Re-export the environment of `dir` (defaults to the current buffer's
--- directory) into the nvim process.
---
--- The export is asynchronous: pass `on_done` to run work that must see the
--- new environment (it is always invoked, with `false` when nothing was
--- applied: reload already in flight, direnv missing, export failed).
---@param dir? string
---@param on_done? fun(applied: boolean)
function Direnv:reload(dir, on_done)
	local progress ---@type internal.Progress|nil

	local function done(applied)
		if progress then
			progress:finish({ message = applied and "done" or "failed" })
			progress = nil
		end
		if on_done then
			vim.schedule(function()
				on_done(applied)
			end)
		end
	end

	if self.refresh then
		done(false)
		return
	end
	self.refresh = true
	dir = dir or vim.fs.dirname(vim.api.nvim_buf_get_name(0))
	if dir == "" then
		dir = vim.fn.getcwd()
	end

	-- nix-direnv evals can take a while: show an LSP-init style spinner
	progress = require("internal.ui.progress").start({
		client = "direnv",
		title = "export",
		message = vim.fn.fnamemodify(dir, ":~"),
	})

	local spawned = pcall(vim.system, { "direnv", "export", "json" }, { cwd = dir }, function(out)
		self.refresh = false
		if out.code ~= 0 then
			done(false)
			return
		end
		local stdout = out.stdout

		local ok, export = pcall(vim.json.decode, stdout)
		if not ok then
			done(false)
			return
		end

		vim.schedule(function()
			for k, v in pairs(export) do
				-- direnv reports removed variables as null
				if v == vim.NIL then
					vim.fn.setenv(k, vim.v.null)
				else
					vim.fn.setenv(k, v)
				end
			end
			done(true)
		end)
	end)

	if not spawned then
		-- direnv is not installed / not executable
		self.refresh = false
		done(false)
	end
end

---@param path string
function Direnv:status(path)
	if self.refresh then
		return
	end
	self.refresh = true
	local dir = vim.fs.dirname(path)
	vim.system({ "direnv", "status", "--json" }, { cwd = dir }, function(out)
		if out.code == 0 then
			local ok, status = pcall(vim.json.decode, out.stdout)
			if ok then
				self.envrc[path] = status.state.foundRC.allowed
			end
		end
		self.refresh = false
	end)
end

return Direnv
