require("mason").setup({ ui = { border = "rounded", height = 0.8 } })
require("mason-lspconfig").setup()
require("mason-nvim-dap").setup()
require("mason-tool-installer").setup({
	ensure_installed = vim.list_extend(
		-- INFO: LSP
		require("utils.lsp").all_lsp_mason(),
		{
			-- INFO: DAP
			"codelldb",
			"debugpy",
			"delve",
			-- INFO: Linter
			-- INFO: Formatter
			"ruff",
			"prettier",
			"stylua",
		}
	),
})
