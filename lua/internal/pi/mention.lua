local M = {}

--- In `oil` buffers mention the entry under the cursor (or the browsed
--- directory when there's none), relative to cwd, instead of the
--- `oil://` buffer path.
---@return { path: string }|nil
function M.oil()
	if vim.bo.filetype ~= "oil" then
		return nil
	end

	local ok, oil = pcall(require, "oil")
	if not ok then
		return nil
	end

	local dir = oil.get_current_dir()
	if not dir then
		return nil
	end

	-- prefer the entry under the cursor, if any
	local entry = oil.get_cursor_entry()
	if entry and entry.name and entry.name ~= ".." then
		dir = (dir:gsub("/+$", "")) .. "/" .. entry.name
	end

	local path = (dir:gsub("/+$", ""))
	local rel = vim.fs.relpath(vim.uv.cwd(), path) or path

	if rel == "" or rel == "." then
		rel = "."
	end

	return { path = rel }
end

return M
