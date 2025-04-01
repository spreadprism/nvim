local M = {}

M.linter_by_ft = {}

---@param filetypes string | string[]
---@param linters string | table
function M.linter(filetypes, linters)
	if type(filetypes) == "string" then
		filetypes = { filetypes }
	end
	if type(linters) == "string" then
		linters = { linters }
	end

	for _, ft in ipairs(filetypes) do
		M.linter_by_ft[ft] = linters
	end
end

return M
