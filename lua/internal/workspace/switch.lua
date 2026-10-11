--- Everything that must happen when the global cwd changes (worktree switch,
--- `<leader>ww`, a plain `:cd`). A single `DirChanged` handler owns the whole
--- routine so the steps run in a known order and exactly once:
---
---   1. drop the dap configs of the tree we are leaving
---   2. unload the old exrc files, remembering their layout
---   3. re-export direnv for the new cwd, and wait for it: the export is
---      async and the env must be in place before anything spawns
---   4. register the new tree as a workspace and mark it as most recently used
---   5. load the matching exrc files under the new tree
---   6. restart LSP clients so they re-root and pick up the new settings
---   7. dispose overseer tasks pinned to the old tree
---   8. retarget/wipe buffers left over from the old tree
---   9. refresh git state and the UI
local M = {}

local registry = require("internal.workspace.registry")
local clean = registry.clean

local group = vim.api.nvim_create_augroup("workspace_switch", { clear = true })

--- Guard against re-entrancy: step 4 `cd`s to the directory we are already in.
local switching = false

--- A cwd change that arrives while a switch is in flight (the direnv step is
--- async) is queued here and replayed when the current one finishes.
---@type { old_cwd: string, new_cwd: string }|nil
local pending = nil

--- Whether the switch routine is currently running. `Workspace:lsp` uses this
--- to skip its own LSP bounce: the routine restarts everything once at the end.
---@return boolean
function M.is_switching()
	return switching
end

--- Path of `path` relative to `dir`, or nil when not inside it.
---@param path string
---@param dir string
---@return string|nil
local function relative(path, dir)
	if path == dir then
		return ""
	end
	local prefix = dir .. "/"
	if path:sub(1, #prefix) == prefix then
		return path:sub(#prefix + 1)
	end
end

--- Unload every loaded exrc file and return the list (load order preserved).
---@return string[]
local function unload_exrc()
	local ok, loader = pcall(require, "exrc.loader")
	if not ok then
		return {}
	end

	local loaded = vim.list_slice(loader.loaded.history)
	for _, path in ipairs(loaded) do
		pcall(loader.unload, path)
	end
	return loaded
end

--- Re-root `loaded` under `new_cwd`, keeping the same relative layout, and load
--- whatever exists. Files that lived outside `old_cwd` are dropped.
---@param loaded string[]
---@param old_cwd string
---@param new_cwd string
local function load_exrc(loaded, old_cwd, new_cwd)
	local ok, loader = pcall(require, "exrc.loader")
	if not ok then
		return
	end

	local candidates = {}
	local seen = {}
	local function add(path)
		path = clean(path)
		if not seen[path] and vim.fn.filereadable(path) == 1 then
			seen[path] = true
			table.insert(candidates, path)
		end
	end

	add(vim.fs.joinpath(new_cwd, vim.g.workspace_file_name))
	for _, path in ipairs(loaded) do
		local rel = relative(clean(path), old_cwd)
		if rel then
			add(vim.fs.joinpath(new_cwd, rel))
		end
	end

	for _, path in ipairs(candidates) do
		if not loader.is_loaded(path) then
			local loaded_ok, err = pcall(loader.load, path)
			if not loaded_ok then
				vim.notify(
					string.format("exrc: failed to load %s\n%s", path, err),
					vim.log.levels.WARN,
					{ title = "exrc" }
				)
			end
		end
	end
end

--- Register the new tree and bump it in the MRU list, so `<leader>ww` offers it
--- and `workspaces.name()` stays accurate.
---
--- Note: `workspaces.open` performs a `cd` to the directory we are already in,
--- which fires a nested `DirChanged`. Its scheduled switch is harmless: by
--- then `prev_cwd` is up to date, so it bails on `old_cwd == new_cwd`.
---@param cwd string
local function activate_workspace(cwd)
	local name = registry.register(cwd)
	if name then
		pcall(require("workspaces").open, name)
	end
end

--- Tasks keep the cwd they were built with, so they are useless (and
--- misleading) after a switch. Also drop the template cache: it is keyed per
--- directory, so coming back to a tree whose task files (justfile, vscode
--- tasks, ...) changed while we were away would serve stale templates.
local function dispose_tasks()
	if not package.loaded["overseer"] then
		return
	end

	local overseer = require("overseer")
	for _, task in ipairs(overseer.list_tasks()) do
		pcall(function()
			task:dispose(true)
		end)
	end
	pcall(overseer.clear_task_cache)
end

--- Buffers from the old tree would re-attach LSP clients rooted in the old
--- path. Retarget them to their counterpart under the new tree when it exists,
--- otherwise wipe them. Modified buffers are always kept.
---@param old_cwd string
---@param new_cwd string
local function migrate_buffers(old_cwd, new_cwd)
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		local name = vim.api.nvim_buf_get_name(buf)
		if
			name ~= ""
			and vim.api.nvim_buf_is_loaded(buf)
			and vim.bo[buf].buftype == ""
			and not vim.bo[buf].modified
		then
			local rel = relative(clean(name), old_cwd)
			if rel and rel ~= "" then
				local counterpart = vim.fs.joinpath(new_cwd, rel)
				local target = vim.fn.filereadable(counterpart) == 1 and counterpart or nil

				for _, win in ipairs(vim.fn.win_findbuf(buf)) do
					vim.api.nvim_win_call(win, function()
						if target then
							vim.cmd.edit(vim.fn.fnameescape(target))
						else
							vim.cmd.enew()
						end
					end)
				end

				pcall(vim.api.nvim_buf_delete, buf, { force = false })
			end
		end
	end
end

local function refresh_ui()
	if package.loaded["gitsigns"] then
		---@diagnostic disable-next-line: param-type-mismatch
		pcall(vim.cmd, "Gitsigns refresh")
	end
	pcall(vim.cmd, "redrawstatus!")
	pcall(vim.cmd, "redrawtabline")
end

--- Run the full switch routine from `old_cwd` to `new_cwd`.
---@param old_cwd string
---@param new_cwd string
function M.switch(old_cwd, new_cwd)
	old_cwd, new_cwd = clean(old_cwd), clean(new_cwd)
	if old_cwd == new_cwd then
		return
	end
	if switching then
		-- replayed once the in-flight switch finishes; only the latest wins
		pending = { old_cwd = old_cwd, new_cwd = new_cwd }
		return
	end

	switching = true

	---@param fn fun()
	---@return boolean ok
	local function step(fn)
		local ok, err = pcall(fn)
		if not ok then
			vim.notify(
				string.format("workspace switch failed\n%s", err),
				vim.log.levels.ERROR,
				{ title = "Workspace" }
			)
		end
		return ok
	end

	local function finish()
		switching = false
		if pending then
			local next_switch = pending
			pending = nil
			M.switch(next_switch.old_cwd, next_switch.new_cwd)
		end
	end

	local loaded ---@type string[]
	if not step(function()
		require("internal.workspace").flush_dap()
		loaded = unload_exrc()
	end) then
		finish()
		return
	end

	-- the export is async and the new env must be visible before exrc handlers
	-- run and LSP clients/tasks spawn: continue once it has been applied
	require("internal.direnv"):reload(new_cwd, function()
		step(function()
			activate_workspace(new_cwd)
			load_exrc(loaded, old_cwd, new_cwd)

			require("internal.workspace").restart_lsp()
			dispose_tasks()
			migrate_buffers(old_cwd, new_cwd)
			refresh_ui()
		end)
		finish()
	end)
end

--- Install the `DirChanged` handler. Idempotent.
function M.setup()
	-- DirChanged does not tell us where we came from, so remember it.
	local prev_cwd = clean(vim.fn.getcwd(-1, -1))

	vim.api.nvim_create_autocmd("DirChanged", {
		group = group,
		desc = "Reload the workspace (exrc, dap, lsp, direnv, buffers) on cwd change",
		callback = function(ev)
			-- only global cwd changes define "the" workspace
			if ev.match ~= "global" then
				return
			end

			local old_cwd = prev_cwd
			local new_cwd = clean(vim.v.event.cwd or ev.file)
			prev_cwd = new_cwd

			-- deferred so callers that `cd` and then keep working on the
			-- buffers themselves (worktrunk's auto_buffer) finish first
			vim.schedule(function()
				M.switch(old_cwd, new_cwd)
			end)
		end,
	})
end

return M
