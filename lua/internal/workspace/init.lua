local M = {}

---@class Workspace
---@field workspaceFolder string
local Workspace = {}
Workspace.__index = Workspace

function M.new()
	local self = setmetatable({
		workspaceFolder = debug.getinfo(2, "S").source:sub(2),
	}, Workspace)

	return self
end

return M
