-- TODO: This should be empty
local ensure_installed = {
	"ruff",
	"prettier",
	"stylua",
}
plugin("williamboman/mason.nvim")
	:lazy(false)
	:dependencies({
		plugin("williamboman/mason-lspconfig.nvim"),
		plugin("jay-babu/mason-nvim-dap.nvim"),
		plugin("WhoIsSethDaniel/mason-tool-installer.nvim"),
	})
	:config(function()
		require("mason").setup({
			registries = {
				"github:nvim-java/mason-registry",
				"github:mason-org/mason-registry",
			},
			ui = { border = "rounded", height = 0.8 },
		})
		require("mason-lspconfig").setup()
		require("mason-nvim-dap").setup()
		--INFO: lsp
		ensure_installed = vim.list_extend(ensure_installed, require("internal.lsp").mason())
		--INFO: dap
		ensure_installed = vim.list_extend(ensure_installed, require("internal.dap").mason())
		ensure_installed = vim.list_extend(ensure_installed, require("internal.formatting").mason())
		require("mason-tool-installer").setup({
			ensure_installed = ensure_installed,
		})
	end)
