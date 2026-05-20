---@class PostgresConnection
---@field name string
---@field username string
---@field password string
---@field host? string
---@field port? number
---@field db? string

---@param workspace Workspace
---@param conn PostgresConnection
---@return Dbab.Connection
return function(workspace, conn)
	conn = vim.tbl_deep_extend("force", {
		host = "127.0.0.1",
		port = 5432,
		db = "",
	}, conn)

	---@type Dbab.Connection
	return {
		name = conn.name,
		url = string.format("postgresql://%s:%s@%s:%d/%s", conn.username, conn.password, conn.host, conn.port, conn.db),
	}
end
