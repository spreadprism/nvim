---@param config dap.Configuration
---@param on_config fun(config: dap.Configuration)
return function(config, on_config)
	local final_config = vim.deepcopy(config)
	final_config.cwd = config.cwd or cwd()
	final_config.request = config.request or "launch"
	on_config(final_config)
end
