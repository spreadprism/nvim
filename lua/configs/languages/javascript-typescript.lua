lsp("svelte", "svelte-language-server")
lsp("ts_ls", "typescript-language-server")
formatter({ "typescript", "javascript", "css" }, "prettier")
formatter("typescriptreact", "prettier", "typescript") -- INFO: Typescript react uses prettier from typescript
linter({ "typescript", "typescriptreact", "javascript", "css" }, "eslint")
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
