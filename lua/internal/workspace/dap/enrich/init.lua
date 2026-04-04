---@class Configuration : dap.Configuration
---@field args? string[]
---@field env? table<string, string>
---@field cwd? string
---@field console? "integratedTerminal" | "externalTerminal" | "internalConsole"

---@param workspace Workspace
---@param config Configuration
---@return Configuration|Configuration[]
return function(workspace, config)
	config = vim.tbl_deep_extend("force", {
		request = "launch",
		cwd = workspace.workspaceDir,
	}, config)

	local ok, module = pcall(require, "internal.workspace.dap.enrich." .. config.type)
	if ok then
		config = module(workspace, config)
	end

	return config
end
