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

require("lspconfig.ui.windows").default_options.border = "rounded"

require("utils.lsp").setup_all_lsp()
