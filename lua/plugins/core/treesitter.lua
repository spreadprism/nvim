plugin("nvim-treesitter-endwise"):on_plugin("nvim-treesitter"):config(false)
plugin("nvim-treesitter-textobjects"):on_plugin("nvim-treesitter"):config(false)
plugin("nvim-treesitter")
	:event_defer()
	:config(function()
		---@diagnostic disable-next-line: missing-fields
		require("nvim-treesitter.configs").setup({
			highlight = { enable = true },
			indent = {
				enable = false,
				disable = { "nix" },
			},
			textobjects = {
				select = {
					enable = false, -- INFO: taken care of by mini.ai
				},
				move = {
					enable = true,
					set_jumps = true,
					goto_next_start = {
						["]f"] = { query = "@function.outer", desc = "Next function" },
						["]p"] = { query = "@parameter.inner", desc = "Next param" },
						["]i"] = { query = "@conditional.inner", desc = "Next conditional" },
						["]I"] = { query = "@conditional.outer", desc = "Next conditional" },
						["]r"] = { query = "@return.inner", desc = "Next return" },
						["]l"] = { query = "@loop.inner", desc = "Next return" },
						["]L"] = { query = "@loop.outer", desc = "Next return" },
					},
					goto_previous_start = {
						["[f"] = "@function.outer",
						["[p"] = { query = "@parameter.inner", desc = "Previous param" },
						["[i"] = { query = "@conditional.inner", desc = "Previous conditional" },
						["[r"] = { query = "@return.inner", desc = "Previous return" },
						["[l"] = { query = "@loop.inner", desc = "Next return" },
					},
					goto_next_end = {},
					goto_previous_end = {},
				},
			},
			endwise = {
				enable = true,
			},
		})
	end)
	:setup(function()
		vim.treesitter.language.register("bash", "dotenv")
		vim.treesitter.language.register("python", "bzl")
	end)
