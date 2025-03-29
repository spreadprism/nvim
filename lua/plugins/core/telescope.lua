plugin("telescope-fzf-native.nvim"):dep_of("telescope.nvim"):after(nil)
plugin("telescope-zf-native.nvim"):dep_of("telescope.nvim"):after(nil)
plugin("telescope.nvim")
	:triggerUIEnter()
	:after(function(_)
		local telescope = require("telescope")
		local actions = require("telescope.actions")
		telescope.setup({
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
	end)
	:keys({
		keymap("n", "<M-g>", internal.telescope.live_grep(), "grep buffer"),
		keymap("n", "<M-G>", internal.telescope.live_grep(true), "grep everything"),
		keymap("n", "<M-f>", keymapCmd("Telescope current_buffer_fuzzy_find theme=ivy"), "fuzzy find buffer"),
		unpack(keymapGroup("<leader>f", "find", {
			keymap("n", "f", keymapCmd("Telescope find_files"), "files"),
			keymap("n", "l", keymapCmd("Telescope resume"), "last"),
			keymap("n", "b", keymapCmd("Telescope buffers"), "buffers"),
			keymap("n", "s", keymapCmd("Telescope lsp_document_symbols"), "symbols"),
		})),
	})
