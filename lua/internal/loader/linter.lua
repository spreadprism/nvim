local M = {}

M.linters_by_ft = {}

---@param ft string | string[]
---@param ... string
function M.linter(ft, ...)
	local linters = { ... }

	if type(ft) == "string" then
		ft = { ft }
	end

	for _, filetype in ipairs(ft) do
		M.formatters_by_ft[filetype] = linters
	end
end

return M
