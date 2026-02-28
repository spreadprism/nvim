---@type table<string, dap.Configuration[]>
local configs = {}

---@type table<string, string[]>
local links = {}

event.on_plugin("nvim-dap", function()
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

---@param config dap.Configuration|dap.Configuration[]
---@return dap.Configuration[]
function M.enrich_config(config)
	local new_configs = {}
	if type(config) == "table" and not vim.islist(config) then
		config = { config }
	end

	for i, cfg in ipairs(config) do
		new_configs[i] = vim.tbl_deep_extend("force", {
			request = "launch",
		}, cfg)
	end

	return new_configs
end

return M
