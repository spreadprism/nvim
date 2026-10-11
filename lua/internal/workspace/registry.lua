--- Workspace registry helpers on top of workspaces.nvim.
---
--- Workspaces are discovered, not hand-registered: every `~/workspace/<name>`
--- directory that contains a workspace file (`.nvim.lua`) is a workspace.
--- `sync()` reconciles the plugin's registry with what is on disk, and
--- `register()` adds one-off directories (e.g. git worktrees living outside
--- the root).
local M = {}

M.root = vim.fs.normalize(vim.fs.joinpath(vim.env.HOME, "workspace"))

---@param path string
---@return string
function M.clean(path)
	return (vim.fs.normalize(path):gsub("/+$", ""))
end

--- Directories under `root` holding a workspace file, keyed by their name.
---@return table<string, string>
function M.discover()
	local found = {}
	local fname = vim.g.workspace_file_name

	local ok, iter = pcall(vim.fs.dir, M.root)
	if not ok then
		return found
	end

	for name, type in iter do
		if type == "directory" or type == "link" then
			local path = vim.fs.joinpath(M.root, name)
			if vim.uv.fs_stat(vim.fs.joinpath(path, fname)) then
				found[name] = M.clean(path)
			end
		end
	end

	return found
end

--- Registered workspaces, keyed by name.
---@return table<string, string>
function M.registered()
	local registered = {}
	for _, entry in ipairs(require("workspaces").get()) do
		registered[entry.name] = M.clean(entry.path)
	end
	return registered
end

--- Name of the workspace matching `path` (defaults to cwd), if any.
---@param path? string
---@return string|nil
function M.name_of(path)
	path = M.clean(path or vim.fn.getcwd())
	for name, registered in pairs(M.registered()) do
		if registered == path then
			return name
		end
	end
end

--- Register `path` as a workspace, unless it already is one. Returns the
--- workspace name.
---@param path? string defaults to cwd
---@param name? string defaults to the directory basename
---@return string|nil
function M.register(path, name)
	path = M.clean(path or vim.fn.getcwd())

	if vim.fn.isdirectory(path) == 0 then
		return nil
	end

	local existing = M.name_of(path)
	if existing then
		return existing
	end

	name = name or vim.fs.basename(path)

	-- another entry may hold the name: drop it when it is stale, otherwise
	-- disambiguate with the parent directory (and a counter as a last resort,
	-- e.g. two worktrees `a/feature` from different repos both named `repo`)
	local registered = M.registered()
	if registered[name] then
		if vim.fn.isdirectory(registered[name]) == 0 then
			require("workspaces").remove(name)
		else
			local base = vim.fs.basename(vim.fs.dirname(path)) .. "/" .. name
			name = base
			local n = 2
			while registered[name] do
				name = base .. "-" .. n
				n = n + 1
			end
		end
	end

	require("workspaces").add(path, name)
	return name
end

--- Register every discovered workspace and drop the ones under `root` whose
--- workspace file (or directory) is gone. Entries outside `root` (worktrees
--- registered on switch) are left alone unless their directory vanished.
---@param opts? { quiet?: boolean }
function M.sync(opts)
	opts = opts or {}
	local ws = require("workspaces")
	local found = M.discover()
	local registered = M.registered()

	local added, moved, removed = 0, 0, 0

	for name, path in pairs(found) do
		if registered[name] ~= path then
			if registered[name] then
				-- same name, different directory: the workspace moved
				ws.remove(name)
				moved = moved + 1
			else
				added = added + 1
			end
			ws.add(path, name)
		end
	end

	for name, path in pairs(registered) do
		local under_root = vim.startswith(path, M.root .. "/")
		local gone = vim.fn.isdirectory(path) == 0
		if (under_root and not found[name]) or gone then
			ws.remove(name)
			removed = removed + 1
		end
	end

	if not opts.quiet then
		vim.notify(
			string.format(
				"Workspaces: %d added, %d moved, %d removed, %d total",
				added,
				moved,
				removed,
				vim.tbl_count(M.registered())
			),
			vim.log.levels.INFO,
			{ title = "Workspaces" }
		)
	end
end

return M
