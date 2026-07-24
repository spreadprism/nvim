local M = {}

--- Search upward from a starting directory for a file or directory by name.
--- Returns the full path of the first match, or nil if none is found.
---@param name string filename or directory name to look for (e.g. "pyproject.toml")
---@param opts? { path?: string, type?: "file"|"directory", stop?: string, create?: boolean, create_path?: string }
---  path: directory to start searching from (defaults to the current buffer's
---        directory, or cwd for unnamed buffers).
---  type: restrict matches to "file" or "directory" (defaults to any).
---  stop: directory at which to stop the upward search (exclusive).
---  create: when true, if no match is found, create the file and return its
---          path (never returns nil).
---  create_path: directory to create the file in when create is true
---               (defaults to the start directory).
---@return string|nil path full path of the match, or nil
function M.find_up(name, opts)
	opts = opts or {}

	local start = opts.path
	if not start then
		local bufname = vim.api.nvim_buf_get_name(0)
		start = bufname ~= "" and vim.fs.dirname(bufname) or vim.fn.getcwd()
	end

	local found = vim.fs.find(name, {
		path = start,
		upward = true,
		type = opts.type,
		stop = opts.stop,
		limit = 1,
	})[1]

	if not found and opts.create then
		found = vim.fs.joinpath(opts.create_path or start, name)
		-- touch the file (create parent dirs and an empty file)
		vim.fn.mkdir(vim.fs.dirname(found), "p")
		local fd = vim.uv.fs_open(found, "a", 420) -- 0644
		if fd then
			vim.uv.fs_close(fd)
		end
	end

	return found
end

return M
