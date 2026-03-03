---@diagnostic disable: inject-field
---@type table<string, dap.Adapter|dap.AdapterFactory>
local adapters = {}

local M = {}

---@type table<string, string[]>
M.links = {}

event.on_plugin("nvim-dap", function()
	local dap = require("dap")

	dap.adapters = vim.tbl_deep_extend("force", dap.adapters, adapters)
	for name, aliases in pairs(M.links) do
		for _, alias in ipairs(aliases) do
			dap.adapters[alias] = dap.adapters[name]
		end
	end
end)

---@param name string
---@param opts dap.Adapter|dap.AdapterFactory
function M.adapter(name, opts)
	adapters[name] = opts

	local ans = {}

	function ans:link(...)
		M.link(name, ...)
	end

	return ans
end

function M.link(name, ...)
	if not M.links[name] then
		M.links[name] = {}
	end

	for _, alias in ipairs({ ... }) do
		table.insert(M.links[name], alias)
	end
end

return M
