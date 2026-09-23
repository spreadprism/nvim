--- Throwaway files and buffers for specs.
---
--- Everything lives under a fresh `tempname()` directory and is removed by
--- `cleanup()`, so specs never depend on the repository's own files (which
--- would make them pass or fail depending on where the checkout sits).
local M = {}

---@type string[]
local dirs = {}

--- A new empty directory that `cleanup()` will remove.
---@return string path
function M.tmpdir()
	local dir = vim.fn.tempname()
	vim.fn.mkdir(dir, "p")
	dirs[#dirs + 1] = dir
	return dir
end

--- Write `lines` to `dir/relative`, creating parent directories.
---@param dir string
---@param relative string
---@param lines? string[]
---@return string path
function M.write(dir, relative, lines)
	local path = vim.fs.joinpath(dir, relative)
	vim.fn.mkdir(vim.fs.dirname(path), "p")
	vim.fn.writefile(lines or {}, path)
	return path
end

--- A nested directory tree with `count` leaf files, for scaling benchmarks.
---@param dir string
---@param count integer
---@return string deepest path of the last created file
function M.tree(dir, count)
	local last = dir
	for index = 1, count do
		last = M.write(dir, string.format("pkg%03d/sub%02d/file_%05d.lua", index % 50, index % 10, index), {})
	end
	return last
end

--- Open `path` in a listed buffer and make it current.
---@param path string
---@return integer bufnr
function M.open(path)
	vim.cmd.edit({ args = { path }, mods = { silent = true } })
	return vim.api.nvim_get_current_buf()
end

--- Delete every temp directory and wipe every non-current buffer.
function M.cleanup()
	for _, dir in ipairs(dirs) do
		vim.fn.delete(dir, "rf")
	end
	dirs = {}

	local current = vim.api.nvim_get_current_buf()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if buf ~= current and vim.api.nvim_buf_is_valid(buf) then
			pcall(vim.api.nvim_buf_delete, buf, { force = true })
		end
	end
end

return M
