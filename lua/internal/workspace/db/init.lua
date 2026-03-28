local M = {}

---@class Connection
---@field id string
---@field name string
---@field type string
---@field url string

---@type Connection[]
local conns = {}

---@class WorkspaceSource
local WorkspaceSource = {}

function WorkspaceSource:name()
	return "workspace"
end

function WorkspaceSource:load()
	return conns
end

function M.clear_connections()
	conns = {}
end

local trigger_update = true

---@param workspace Workspace
---@param type string
---@param conn Connection
---@overload fun(type: "mysql", conn: MysqlConnection)
function M.add_connection(workspace, type, conn)
	conn = require("internal.workspace.db." .. type)(workspace, conn)
	conn.type = type
	conn.id = conn.name
	table.insert(conns, conn)
	vim.defer_fn(function()
		if trigger_update then
			trigger_update = false
			require("dbee.api").core.source_reload("workspace")

			vim.defer_fn(function()
				trigger_update = true
			end, 300)
		end
	end, 300)
end

M.source = WorkspaceSource

return M
