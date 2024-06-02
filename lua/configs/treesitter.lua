require("nvim-treesitter.configs").setup({
	highlight = { enable = true },
	indent = { enable = true },
	textobjects = {
		select = {
			enable = true,
			keymaps = {
				["af"] = "@function.outer",
				["if"] = "@function.inner",

				["ac"] = "@class.outer",
				["ic"] = "@class.inner",

				["ap"] = "@parameter.outer",
				["ip"] = "@parameter.inner",

				["ai"] = "@conditional.outer",
				["ii"] = "@conditional.inner",
			},
		},
		move = {
			enable = true,
			set_jumps = true,
			goto_next_start = {
				["]f"] = { query = "@function.outer", desc = "Next function" },
				["]c"] = { query = "@class.outer", desc = "Next class" },
			},
			goto_next_end = {
				["]F"] = "@function.outer",
				["]C"] = "@class.outer",
			},
			goto_previous_start = {
				["[f"] = "@function.outer",
				["[c"] = "@class.outer",
			},
			goto_previous_end = {
				["[F"] = "@function.outer",
				["[C"] = "@class.outer",
			},
		},
	},
	endwise = {
		enable = true,
	},
	ensure_installed = {
		-- Languages
		"bash",
		"make",
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
