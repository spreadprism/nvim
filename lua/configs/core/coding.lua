local treesitter = plugin("nvim-treesitter/nvim-treesitter")
	:event("BufRead")
	:dependencies({
		plugin("nvim-treesitter/nvim-treesitter-textobjects"):event("VeryLazy"):enabled(false), -- TODO: Config textobjects
	})
	:config(function()
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
			ensure_installed = require("internal.treesitter").ensure_installed(),
		})
		vim.treesitter.language.register("bash", "dotenv")
	end)
plugin("windwp/nvim-ts-autotag"):event({ "BufReadPre", "BufNewFile" }):opts({})
plugin("altermo/ultimate-autopair.nvim"):event({ "InsertEnter", "CmdlineEnter" }):opts({})
plugin("RRethy/nvim-treesitter-endwise"):dependencies(treesitter):event("VeryLazy")
plugin("kylechui/nvim-surround"):event("VeryLazy"):opts({})
plugin("abecodes/tabout.nvim"):dependencies({ "hrsh7th/nvim-cmp", treesitter }):event("InsertCharPre"):opts({
	act_as_shift_tab = true,
}) -- TODO: Fix the plugin, its flaky
plugin("echasnovski/mini.surround"):event("VeryLazy"):opts({
	mappings = {
		delete = "",
		find = "",
		find_left = "",
		highlight = "",
		replace = "",
		update_n_lines = "",
		suffix_last = "",
		suffix_next = "",
	},
})
plugin("echasnovski/mini.ai"):event("VeryLazy"):opts({
	custom_textobjects = {
		-- f = spec_treesitter({ a = "@function.outer", i = "@function.inner" }),
		c = false,
		p = false,
		i = false,
	},
})
plugin("echasnovski/mini.move"):event("VeryLazy"):opts({
	mappings = {
		up = "<M-k>",
		down = "<M-j>",
		right = "",
		left = "",
		line_left = "",
		line_right = "",
		line_down = "<M-j>",
		line_up = "<M-k>",
	},
})
plugin("numToStr/Comment.nvim"):event("VeryLazy"):opts({})
plugin("roobert/search-replace.nvim"):event("VeryLazy"):opts({})
