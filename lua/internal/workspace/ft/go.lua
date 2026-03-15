local M = {}

---@class Go
---@field private workspace Workspace
local Go = {}

function M:go(workspace)
	return setmetatable({
		workspace = workspace,
	}, { __index = Go })
end

---@param dir? string the cmd path, if not provided, ${workspaceFolder}/cmd will be used
---@return dap.Configuration[]
function Go:cmd_configs(dir)
	dir = dir or vim.fs.joinpath(self.workspace.workspaceFolder, "cmd")

	return {}
end

return M
