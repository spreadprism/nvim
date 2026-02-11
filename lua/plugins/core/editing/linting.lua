-- TODO: add ast_grep

local function get_client()
	local clients = vim.lsp.get_clients({ bufnr = 0 })

	clients = vim.tbl_filter(function(c)
		return c.name ~= "copilot" and c.name ~= "ast_grep"
	end, clients)

	return clients[1] or {}
end

plugin("lint"):event("DeferredUIEnter"):opts(false):after(function()
	local lint = require("lint")
	lint.linters_by_ft =
		vim.tbl_deep_extend("force", lint.linters_by_ft, require("internal.loader.linter").linters_by_ft)

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
