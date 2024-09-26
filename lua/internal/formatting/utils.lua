local M = {}

---@type Formatter[]
local formatters = {}

---@param formatter Formatter
M.insert = function(formatter)
	table.insert(formatters, formatter)
end

M.list_formatters_mason = function()
	return vim.tbl_filter(
		---@param formatter Formatter
		function(formatter)
			return formatter.install_mason
		end,
		---@param formatter Formatter
		vim.tbl_map(function(formatter)
			return formatter.mason_name
		end, formatters)
	)
end

M.list_formatters = function()
	return formatters
end

return M
