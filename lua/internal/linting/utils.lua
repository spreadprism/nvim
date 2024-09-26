local M = {}

---@type Linter[]
local linters = {}

---@param linter Linter
M.insert = function(linter)
	table.insert(linters, linter)
end

M.list_linters_mason = function()
	return vim.tbl_filter(
		---@param linter Linter
		function(linter)
			return linter.install_mason
		end,
		---@param linter Linter
		vim.tbl_map(function(linter)
			return linter.mason_name
		end, linters)
	)
end

M.list_linters = function()
	return linters
end

return M
