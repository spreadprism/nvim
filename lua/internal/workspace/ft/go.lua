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

	local configs = {}
	-- for each dir in dir we need to generate a config
	for name, type in vim.fs.dir(dir) do
		if type == "directory" then
			local program = vim.fs.joinpath(dir, name, "main.go")

			table.insert(configs, {
				name = "cmd:" .. name,
				type = "go",
				program = program,
			})
		end
	end

	return configs
end

return M
