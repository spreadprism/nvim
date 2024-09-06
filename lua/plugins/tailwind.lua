plugin("luckasRanarison/tailwind-tools.nvim")
	:name("tailwind-tools")
	:build(":UpdateRemotePlugins")
	:dependencies({
		{
			"nvim-treesitter/nvim-treesitter",
			"nvim-telescope/telescope.nvim", -- optional
			"neovim/nvim-lspconfig", -- optional
		},
	})
	:opts({
		document_color = {
			enabled = false,
		},
	})
	:event("VeryLazy")
