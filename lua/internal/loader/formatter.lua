local M = {}

M.formatters_by_ft = {}

---@param ft string | string[]
---@param ... string
function M.formatter(ft, ...)
	local formatters = { ... }

	if type(ft) == "string" then
		ft = { ft }
	end

	for _, filetype in ipairs(ft) do
		M.formatters_by_ft[filetype] = formatters
	end
end

return M
