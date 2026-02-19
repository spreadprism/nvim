---@diagnostic disable: inject-field
---@type table<string, dap.Adapter|dap.AdapterFactory>
local adapters = {}

---@type table<string, string[]>
local links = {}

on_plugin("nvim-dap", function()
	local dap = require("dap")

	dap.adapters = vim.tbl_deep_extend("force", dap.adapters, adapters)
	for name, aliases in pairs(links) do
		for _, alias in ipairs(aliases) do
			dap.adapters[alias] = dap.adapters[name]
		end
	end
end)

local M = {}

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
	if not links[name] then
		links[name] = {}
	end

	for _, alias in ipairs({ ... }) do
		table.insert(links[name], alias)
	end
end

return M
