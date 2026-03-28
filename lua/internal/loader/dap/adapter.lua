---@diagnostic disable: inject-field
---@type table<string, dap.Adapter|dap.AdapterFactory>
local adapters = {}

local M = {}

event.on_plugin("nvim-dap", function()
	local dap = require("dap")
	dap.adapters = vim.tbl_deep_extend("force", dap.adapters, adapters)
end)

---@param names string|string[]
---@param opts dap.Adapter|dap.AdapterFactory
function M.adapter(names, opts)
	if type(names) == "string" then
		names = { names }
	end

	for _, name in ipairs(names) do
		adapters[name] = opts
	end
end

return M
