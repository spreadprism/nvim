---@class MariadbConnection
---@field name string
---@field username string
---@field password string
---@field host? string
---@field port? number
---@field db? string
---@field hooks? Dbab.HooksConfig Lifecycle hooks for this connection only
---@field disable-ssl? boolean

---@param workspace Workspace
---@param conn MariadbConnection
---@return Dbab.Connection
return function(workspace, conn)
	---@type MariadbConnection
	conn = vim.tbl_deep_extend("force", {
		host = "127.0.0.1",
		port = 3306,
		db = "",
	}, conn)

	local query = conn["disable-ssl"] and "?ssl=0" or ""

	---@type Dbab.Connection
	return {
		name = conn.name,
		url = string.format(
			"mariadb://%s:%s@%s:%d/%s%s",
			conn.username,
			conn.password,
			conn.host,
			conn.port,
			conn.db,
			query
		),
		hooks = conn.hooks,
	}
end
