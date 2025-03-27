plugin("nvim-treesitter-textobjects"):for_cat("core"):on_plugin("nvim-treesitter"):after(nil)
plugin("nvim-treesitter"):for_cat("core"):triggerUI():after(function(plugin)
	require("nvim-treesitter.configs").setup({
		highlight = { enable = true },
		indent = { enable = true },
		textobjects = {
			select = {
				enable = false, -- INFO: taken care of by mini.ai
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
	})
	vim.treesitter.language.register("bash", "dotenv")
	vim.treesitter.language.register("python", "bzl")
end)
