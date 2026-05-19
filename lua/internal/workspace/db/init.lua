local M = {}

---@class Connection
---@field id string
---@field name string
---@field type string
---@field url string

---@class WorkspaceSource : Source
---@field providers table<string, fun(): Connection[]>
---@field refreshing boolean
local WorkspaceSource = {}
local providers = {}

function WorkspaceSource:name()
	return "workspace"
end

---@return ConnectionParams[]
function WorkspaceSource:load()
	---@type ConnectionParams[]
	local conn = {}

	for _, provider in pairs(providers) do
		vim.list_extend(conn, provider())
	end

	return conn
end

function WorkspaceSource:refresh()
	if not self.refreshing then
		self.refreshing = true
		vim.defer_fn(function()
			self.refreshing = false
		end, 300)
	end
end

---@param name string
---@param conn Dbab.Connection
function WorkspaceSource:register(name, conn)
	if name == nil then
		return
	end

	local connections = require("dbab.config").options.connections

	---@type Dbab.Connection
	local new_conn = {
		name = conn.name,
		url = conn.url,
		workspace = name,
	}

	table.insert(connections, new_conn)

	require("dbab.config").options.connections = connections
end

---@param name string
function WorkspaceSource:clear(name)
	local connections = require("dbab.config").options.connections
	local new = {}

	for _, conn in ipairs(connections) do
		if conn.workspace ~= name then
			table.insert(new, conn)
		end
	end

	require("dbab.config").options.connections = new
end

M.source = WorkspaceSource

return M
