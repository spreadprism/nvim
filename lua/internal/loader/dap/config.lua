---@type table<string, dap.Configuration[]>
local configs = {}

---@type table<string, string[]>
local links = {}

on_plugin("nvim-dap", function()
	local dap = require("dap")
	dap.configurations = vim.tbl_deep_extend("force", dap.configurations, configs)

	for type, aliases in pairs(links) do
		for _, alias in ipairs(aliases) do
			dap.configurations[alias] = dap.configurations[type]
		end
	end
end)

local M = {}

---@param type string
---@param config dap.Configuration
function M.config(type, config)
	if not configs[type] then
		configs[type] = {}
	end

	table.insert(configs[type], config)

	local ans = {}

	function ans:link(...)
		M.link(type, ...)
	end

	return ans
end

function M.link(type, ...)
	if not links[type] then
		links[type] = {}
	end

	for _, alias in ipairs({ ... }) do
		table.insert(links[type], alias)
	end
end

return M
