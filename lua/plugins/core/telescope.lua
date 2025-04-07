plugin("telescope-fzf-native.nvim"):dep_of("telescope.nvim"):config(false)
plugin("telescope-zf-native.nvim"):dep_of("telescope.nvim"):config(false)
plugin("telescope-dap.nvim"):dep_of("telescope.nvim"):config(false)
plugin("telescope-git-conflicts.nvim"):for_cat("git"):dep_of("telescope.nvim"):config(false)
plugin("telescope.nvim")
	:on_require("telescope")
	:cmd("Telescope")
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
					find_command = function()
						local blacklist = vim.tbl_map(function(pattern)
							return "--glob=!" .. pattern
						end, {
							".git/*",
							"**/target/*",
							"**/.cache/*",
							"**/node_modules/*",
							".venv",
							unpack(vim.g.grep_blacklist_pattern or {}),
						})
						return { "rg", "-uuu", "--files", "--hidden", unpack(blacklist) }
					end,
					theme = "ivy",
				},
				live_grep = {
					theme = "ivy",
				},
				current_buffer_fuzzy_find = {
					theme = "ivy",
				},
			},
			extensions = {
				["zf-native"] = {
					generic = {
						enable = false,
					},
				},
				["fzf"] = {
					override_file_sorter = false,
				},
			},
		})
		pcall(require("telescope").load_extension, "fzf")
		pcall(require("telescope").load_extension, "zf-native")
		pcall(require("telescope").load_extension, "dap")
		pcall(require("telescope").load_extension, "conflicts")
	end)
	:keys({
		kmap("n", "<M-g>", function()
			require("telescope.builtin").live_grep({
				search_dirs = { vim.fn.expand("%:p") },
				prompt_title = "grep buffer",
			})
		end, "grep buffer"),
		kmap("n", "<M-G>", function()
			require("telescope.builtin").live_grep({
				prompt_title = "grep global",
			})
		end, "grep everything"),
		kmap("n", "<M-f>", kcmd("Telescope current_buffer_fuzzy_find"), "fuzzy find buffer"),
		kgroup("<leader>f", "find", {}, {
			kmap("n", "f", kcmd("Telescope find_files"), "files"),
			kmap("n", "l", kcmd("Telescope resume"), "last"),
			kmap("n", "c", kcmd("Telescope conflicts"), "conflicts"),
			kmap("n", "s", kcmd("Telescope lsp_document_symbols"), "symbols"),
		}),
	})
