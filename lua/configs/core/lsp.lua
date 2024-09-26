local neoconf = plugin("folke/neoconf.nvim"):opts({ plugins = { lua_ls = { enabled = true } } })
plugin("neovim/nvim-lspconfig"):event("VeryLazy"):dependencies({ neoconf, "lewis6991/hover.nvim" }):config(function()
	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(ev)
			-- Enable completion triggered by <c-x><c-o>
			vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
			local opts = { buffer = ev.buf }
			keybind("n", "K", function()
				local api = vim.api
				local hover_win = vim.b.hover_preview
				if hover_win and api.nvim_win_is_valid(hover_win) then
					api.nvim_set_current_win(hover_win)
				else
					require("hover").hover()
				end
			end, "Show hover information", opts):register()
			keybind("n", "<f2>", vim.lsp.buf.rename, "Show hover information", opts):register()

			local lspgroup = keybind_group("<leader>l", "language server")
			lspgroup:register({
				keybind({ "n", "v" }, "a", vim.lsp.buf.code_action, "Show code actions", opts),
			})
			keybind({ "n", "v" }, "gd", require("telescope.builtin").lsp_definitions, "Go to definition"):register()
			keybind({ "n", "v" }, "gr", require("telescope.builtin").lsp_references, "Go to reference"):register()
		end,
	})
	-- Symbols
	vim.fn.sign_define("DiagnosticSignError", { text = "", texthl = "DiagnosticSignError" })
	vim.fn.sign_define("DiagnosticSignWarn", { text = "", texthl = "DiagnosticSignWarn" })
	vim.fn.sign_define("DiagnosticSignInfo", { text = "", texthl = "DiagnosticSignInfo" })
	vim.fn.sign_define("DiagnosticSignHint", { text = "󰌵", texthl = "DiagnosticSignHint" })

	vim.diagnostic.config({
		signs = {
			--support diagnostic severity / diagnostic type name
			text = {
				[vim.diagnostic.severity.ERROR] = " ",
				[vim.diagnostic.severity.WARN] = " ",
				[vim.diagnostic.severity.HINT] = "󰌵",
				[vim.diagnostic.severity.INFO] = " ",
			},
		},
	})

	vim.cmd([[highlight DiagnosticUnderlineError guifg=#db4b4b]])
	vim.cmd([[highlight DiagnosticUnderlineWarn guifg=#e0af68]])
	vim.cmd([[highlight DiagnosticDeprecated guifg=#e0af68]])
	vim.cmd([[highlight DiagnosticUnderlineInfo guifg=#0db9d7]])
	vim.cmd([[highlight DiagnosticInfo guifg=#0db9d7]])
	vim.cmd([[highlight DiagnosticUnderlineInfo guifg=#1abc9c]])

	require("lspconfig.ui.windows").default_options.border = "rounded"

	---@diagnostic disable-next-line: missing-fields
	require("lspconfig").jdtls.setup({})
	require("internal.lsp").configure_all_lsp()
end)
