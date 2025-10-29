lsp("ast_grep")
	:cmd({ "ast-grep", "lsp", "--config", vim.fs.joinpath(LUA_PATH, "rules", "sgconfig.yml") })
	:root_markers(cwd(), ".git", "sgconfig.yaml", "sgconfig.yml")
