local function get_client()
	local clients = vim.lsp.get_clients({ bufnr = 0 })

	clients = vim.tbl_filter(function(c)
		return c.name ~= "copilot" and c.name ~= "ast_grep"
	end, clients)

	return clients[1] or {}
end
vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
	callback = function()
		local client = get_client()
		if not client.initialized then
			vim.defer_fn(function()
				client = get_client()
				require("lint").try_lint(nil, { cwd = client.root_dir or cwd() })
			end, 1000) -- HACK: we set 1 second of wait, but we should wait for init event instead
		else
			require("lint").try_lint(nil, { cwd = client.root_dir or cwd() })
		end
	end,
})
plugin("nvim-lint")
	:on_require("lint")
	:config(function()
		require("lint").linters_by_ft = require("internal.linter").linter_by_ft
	end)
	:event_defer()
