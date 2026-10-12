local ctx = workspace:ctx()

ctx:db("mysql", {
	name = "mysql-test",
	username = "root",
	password = "root",
	db = "testdb",
})

ctx:db("postgres", {
	name = "postgres-test",
	username = "postgres",
	password = "postgres",
})

ctx:lsp({
	nixd = function(config, dir)
		return vim.tbl_deep_extend(
			"force",
			config,
			---@type vim.lsp.Config
			{
				cmd = { "devenv", "lsp" },
				filetypes = { "nix" },
				root_dir = dir,
				settings = nil,
			}
		)
	end,
})
