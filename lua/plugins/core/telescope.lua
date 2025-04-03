plugin("telescope-fzf-native.nvim"):dep_of("telescope.nvim"):config(false)
plugin("telescope-zf-native.nvim"):dep_of("telescope.nvim"):config(false)
plugin("telescope-dap.nvim"):dep_of("telescope.nvim"):config(false)
plugin("telescope.nvim")
	:for_cat("core")
	:event_ui()
	:config(function()
		local actions = require("telescope.actions")
		require("telescope").setup({
			defaults = {
				mappings = {
					i = {
						["<Tab>"] = actions.move_selection_next,
						["<S-Tab>"] = actions.move_selection_previous,
						["<M-m>"] = actions.toggle_selection,
						["<C-q>"] = actions.close,
					},
					n = {
						["<Tab>"] = actions.toggle_selection,
					},
				},
			},
			pickers = {
				find_files = {
					find_command = internal.telescope.find_command,
					theme = "dropdown",
				},
				live_grep = {
					theme = "ivy",
				},
				current_buffer_fuzzy_find = {
					theme = "ivy",
				},
			},
			extensions = {
				["zf-native"] = internal.telescope.zf_native,
				["fzf"] = internal.telescope.fzf,
			},
		})
		pcall(require("telescope").load_extension, "fzf")
		pcall(require("telescope").load_extension, "zf-native")
		pcall(require("telescope").load_extension, "dap")
	end)
	:keys({
		kmap("n", "<M-g>", internal.telescope.live_grep(), "grep buffer"),
		kmap("n", "<M-G>", internal.telescope.live_grep(true), "grep everything"),
		kmap("n", "<M-f>", kcmd("Telescope current_buffer_fuzzy_find"), "fuzzy find buffer"),
		kgroup("<leader>f", "find", {}, {
			kmap("n", "f", kcmd("Telescope find_files"), "files"),
			kmap("n", "l", kcmd("Telescope resume"), "last"),
			kmap("n", "s", kcmd("Telescope lsp_document_symbols"), "symbols"),
		}),
	})
