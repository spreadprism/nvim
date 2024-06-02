local M = {}
local dap = require("dap")

local __base_configs = {}
local dap_config_module = "dap.configurations"
M.configs = function(ft)
	if __base_configs[ft] == nil then
		local ok, configs = pcall(require, dap_config_module .. "." .. ft)
		if ok then
			__base_configs[ft] = configs
		end
	end
	return vim.deepcopy(__base_configs[ft]) or {}
end

M.init_adapters = function()
	for _, adapter in ipairs(require("utils.module").submodules(dap_config_module)) do
		dap.adapters[adapter] = require(dap_config_module .. "." .. adapter)
	end
end

--- @param ft string | nil
M.init_configurations = function(ft)
	if ft == nil then
		for _, module in ipairs(require("utils.module").submodules(dap_config_module)) do
			M.init_configurations(module)
		end
	else
		local configs = M.configs(ft)
		local temp_configs = {}
		for _, config in ipairs(configs) do
			config.name = "(NVIM) " .. config.name
			table.insert(temp_configs, config)
		end
		require("dap").configurations[ft] = vim.list_extend(temp_configs, require("dap").configurations[ft] or {})
	end
end

--- @param ft string | nil
M.refresh_configurations = function(ft)
	if ft == nil then
		require("dap").configurations = {}
	else
		require("dap").configurations[ft] = {}
	end
	M.init_configurations(ft)
end

return M
