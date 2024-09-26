plugin("nvim-neotest/neotest")
	:event("VeryLazy")
	:dependencies({
		-- INFO: core
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-treesitter/nvim-treesitter",
		-- INFO: Adapters
		"nvim-neotest/neotest-go",
		"nvim-neotest/neotest-python",
		"rouge8/neotest-rust",
		"marilari88/neotest-vitest",
	})
	:config(function()
		require("neotest").setup({
			adapters = {
				require("neotest-python")({
					python = function()
						return require("venv-selector").python()
					end,
				}),
				require("neotest-go")({
					recursive_run = true,
				}),
				require("neotest-rust"),
				require("neotest-vitest")({
					-- Filter directories when searching for test files. Useful in large projects (see Filter directories notes).
					filter_dir = function(name, rel_path, root)
						return name ~= "node_modules"
					end,
				}),
			},
			summary = {
				mappings = {
					expand = { "<tab>" },
					jumpto = "<CR>",
				},
			},
		})
	end)
