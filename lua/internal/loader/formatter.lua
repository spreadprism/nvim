---@type table<string, string[]>
local formatters_ft = {}

event.on_plugin("conform", function()
	local conform = require("conform")
	conform.formatters_by_ft = vim.tbl_deep_extend("force", conform.formatters_by_ft, formatters_ft)
end)

---@param ft string | string[]
---@param ... string
return function(ft, ...)
	local formatters = { ... }

	if type(ft) == "string" then
		ft = { ft }
	end

	for _, filetype in ipairs(ft) do
		formatters_ft[filetype] = formatters
	end
end
