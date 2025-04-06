local M = {}

M.formatter_by_ft = {}

---@param filetypes string | string[]
---@param formatters string | table
function M.formatter(filetypes, formatters)
	if type(filetypes) == "string" then
		filetypes = { filetypes }
	end
	if type(formatters) == "string" then
		formatters = { formatters }
	end

	for _, ft in ipairs(filetypes) do
		M.formatter_by_ft[ft] = formatters
	end
end

return M
