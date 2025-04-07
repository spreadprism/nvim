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
---@field port? string
---@field db? string

---@param conn_name string
---@param opts MysqlOpts
function M.add_mysql_conn(conn_name, opts)
	---@type MysqlOpts
	opts = vim.tbl_deep_extend("force", {
		host = "127.0.0.1",
		port = "3306",
		db = "",
	}, opts)
	M.add_connection({
		name = conn_name,
		type = "mysql",
		url = string.format("%s:%s@tcp(%s:%s)/%s", opts.username, opts.password, opts.host, opts.port, opts.db),
	})
end

M.source = WorkspaceSource

return M
