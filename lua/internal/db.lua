local M = {}

local conns = {}
---@class WorkspaceSource
WorkspaceSource = {}

function WorkspaceSource:name()
	return "workspace"
end

function WorkspaceSource:load()
	return conns
end

function M.clear_connections()
	conns = {}
end

function M.add_connection(conn)
	conn.id = conn.name
	table.insert(conns, conn)
end

---@class MysqlOpts
---@field username string
---@field password string
---@field host? string
---@field port? number
---@field db? string

---@param conn_name string
---@param opts MysqlOpts
function M.add_mysql_conn(conn_name, opts)
	opts.host = opts.host or "127.0.0.1"
	opts.port = opts.port or 3306
	opts.db = opts.db or ""
	M.add_connection({
		name = conn_name,
		type = "mysql",
		url = string.format("%s:%s@tcp(%s:%d)/%s", opts.username, opts.password, opts.host, opts.port, opts.db),
	})
end

M.source = WorkspaceSource

M.layout = function()
	local o = {
		egg = nil,
		windows = {},
		on_switch = opts.on_switch or "immutable",
		is_opened = false,
		drawer_width = opts.drawer_width or 40,
		result_height = opts.result_height or 20,
		call_log_height = opts.call_log_height or 20,
	}
	setmetatable(o, self)
	self.__index = self
	return o
end

return M
