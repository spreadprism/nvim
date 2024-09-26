plugin("williamboman/mason.nvim")
	:lazy(false)
	:dependencies({
		"williamboman/mason-lspconfig.nvim",
		"jay-babu/mason-nvim-dap.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
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
		local ensure_installed = {}
		-- INFO: Lsp
		ensure_installed = vim.list_extend(ensure_installed, require("internal.lsp").mason())
		-- INFO: Dap
		ensure_installed = vim.list_extend(ensure_installed, require("internal.dap").mason())
		-- INFO: Formatters
		ensure_installed = vim.list_extend(ensure_installed, require("internal.formatting").mason())
		-- INFO: Linters
		ensure_installed = vim.list_extend(ensure_installed, require("internal.linting").mason())
		require("mason-tool-installer").setup({
			ensure_installed = ensure_installed,
		})
	end)
