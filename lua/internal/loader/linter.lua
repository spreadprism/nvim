---@type table<string, string[]>
local linters_ft = {}

event.on_plugin("lint", function()
	local lint = require("lint")
	lint.linters_by_ft = vim.tbl_deep_extend("force", lint.linters_by_ft, linters_ft)
end)

---@param ft string | string[]
---@param ... string
return function(ft, ...)
	local linters = { ... }

	if type(ft) == "string" then
		ft = { ft }
	end

	for _, filetype in ipairs(ft) do
		linters_ft[filetype] = linters
	end
end
