plugin("benlubas/molten-nvim")
	:build(":UpdateRemotePlugins")
	:init(function()
		vim.g.molten_output_win_max_height = 20
		vim.g.molten_auto_open_output = false
		vim.g.molten_wrap_output = true
		vim.g.molten_virt_text_output = true
		vim.g.molten_virt_lines_off_by_1 = true
	end)
	:event("VeryLazy")
	:config("configs.notebook")

plugin("quarto-dev/quarto-nvim")
	:dependencies({
		plugin("jmbuhr/otter.nvim"):opts({
			verbose = {
				no_code_found = false,
			},
		}),
		"nvim-treesitter/nvim-treesitter",
	})
	:opts({
		lspFeatures = {
			-- NOTE: put whatever languages you want here:
			languages = { "python" },
			chunks = "all",
			diagnostics = {
				enabled = true,
				triggers = { "BufWritePost" },
			},
			completion = {
				enabled = true,
			},
		},
		keymap = {
			-- NOTE: setup your own keymaps:
			-- hover = "K",
			definition = "gd",
			references = "gr",
		},
		codeRunner = {
			enabled = true,
			default_method = "molten",
		},
	})
	:ft({ "markdown", "quarto" })

plugin("GCBallesteros/jupytext.nvim")
	:opts({
		style = "markdown",
		output_extension = "md",
		force_ft = "markdown",
	})
	:event("VeryLazy")

-- TODO: Add tree-sitter objects for cell navigation
-- TODO: Add Hydra code runner
