---@class Configuration : dap.Configuration
---@field args? string[]
---@field env? table<string, string>
---@field cwd? string
---@field profile "dev"|"prod"|string

---@param workspace Workspace
---@param config Configuration
---@return Configuration
return function(workspace, config)
	config = vim.tbl_deep_extend("force", {
		request = "launch",
		cwd = workspace.workspaceDir,
		profile = "dev",
	}, config)

	local ok, module = pcall(require, "internal.workspace.dap.enrich." .. config.type)
	if ok then
		config = module(workspace, config)
	end

	return config
end
