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

local trigger_update = true
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
