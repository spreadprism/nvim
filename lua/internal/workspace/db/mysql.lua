---@class MysqlConnection
---@field name string
---@field username string
---@field password string
---@field host? string
---@field port? number
---@field db? string

---@param workspace Workspace
---@param conn MysqlConnection
---@return ConnectionParams
return function(workspace, conn)
	conn = vim.tbl_deep_extend("force", {
		host = "127.0.0.1",
		port = 3306,
		db = "",
	}, conn)

	---@type ConnectionParams
	return {
		name = conn.name,
		id = conn.name,
		url = string.format("%s:%s@tcp(%s:%d)/%s", conn.username, conn.password, conn.host, conn.port, conn.db),
	}
end
