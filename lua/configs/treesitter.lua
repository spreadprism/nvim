require("nvim-treesitter.configs").setup({
	endwise = {
		enable = true,
	},
	ensure_installed = {
		-- Languages
		"bash",
		"c",
		"javascript",
		"lua",
		"python",
		"rust",
		"go",
		"tsx",
		"typescript",
		-- Config formats
		"jsdoc",
		"json",
		"toml",
		"yaml",
		-- others
		"html",
		"luadoc",
		"luap",
		"markdown",
		"markdown_inline",
		"query",
		"regex",
		"vim",
		"vimdoc",
	},
})
