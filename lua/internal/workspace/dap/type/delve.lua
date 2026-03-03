---@param config dap.Configuration
---@return dap.Configuration
return function(config)
	local new_configs = {}

	new_configs = vim.tbl_deep_extend("force", {
		mode = "exec",
	}, config)

	return new_configs
end
