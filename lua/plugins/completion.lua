plugin("hrsh7th/nvim-cmp"):event("VeryLazy"):config("configs.completion"):dependencies({
	"hrsh7th/cmp-path",
	"hrsh7th/cmp-buffer",
	"hrsh7th/cmp-cmdline",
	"hrsh7th/cmp-nvim-lua",
	"petertriho/cmp-git",
	plugin("hrsh7th/cmp-nvim-lsp"):dependencies("neovim/nvim-lspconfig"),
})
