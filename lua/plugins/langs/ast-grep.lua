lsp("ast_grep")
	:cmd("ast-grep", "lsp", "--config", vim.fs.joinpath(LUA_PATH, "rules", "sgconfig.yml"))
	:root_markers(cwd(), ".git")
	:ft("c", "cpp", "rust", "go", "java", "python", "javascript", "typescript", "html", "css", "kotlin", "dart", "lua")
