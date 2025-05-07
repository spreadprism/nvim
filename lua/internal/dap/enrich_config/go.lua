---@param config dap.Configuration
---@param on_config fun(config: dap.Configuration)
return function(config, on_config)
	local final_config = vim.deepcopy(config)
	final_config.outputMode = config.outputMode or "remote"
	require("internal.dap.enrich_config.all")(final_config, on_config)
end
