local function get_client()
	local clients = vim.lsp.get_clients({ bufnr = 0 })

	clients = vim.tbl_filter(function(c)
		return c.name ~= "copilot" and c.name ~= "ast_grep"
	end, clients)

	return clients[1] or {}
end

plugin("lint"):event("DeferredUIEnter"):opts(false):after(function()
	vim.api.nvim_create_autocmd({ "BufWritePost" }, {
		callback = function()
			local client = get_client()
			if not client.initialized then
				vim.defer_fn(function()
					client = get_client()
					require("lint").try_lint(nil, { cwd = client.root_dir or vim.fn.getcwd() })
				end, 1000) -- HACK: we set 1 second of wait, but we should wait for init event instead
			else
				require("lint").try_lint(nil, { cwd = client.root_dir or vim.fn.getcwd() })
			end
		end,
	})
end)

lsp("ast_grep")
	:cmd({
		"ast-grep",
		"lsp",
		"--config",
		vim.fs.joinpath(nixCats.configDir, "lua", "ast_grep_rules", "sgconfig.yml"),
	})
	:root_markers({ vim.fn.getcwd(), ".git", "sgconfig.yaml", "sgconfig.yml" })
	:display(false)
