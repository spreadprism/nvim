local telescope = plugin("nvim-telescope/telescope.nvim")
	:tag("0.1.6")
	:event("VeryLazy")
	:dependencies("nvim-lua/plenary.nvim")
	:config(function()
		local telescope = require("telescope")
		telescope.setup({
			defaults = {
				mappings = {
					i = {
						["<Tab>"] = require("telescope.actions").move_selection_next,
						["<S-Tab>"] = require("telescope.actions").move_selection_previous,
						["<C-q>"] = require("telescope.actions").close,
					},
				},
			},
			pickers = {
				find_files = {
					find_command = vim.list_extend(
						{
							"rg",
							"-uuu",
							"--files",
							"--hidden",
						},
						vim.tbl_map(function(pattern)
							return "--glob=!" .. pattern
						end, {
							".git/*",
							"**/node_modules/*",
							"**/target/*",
							"**/.cache/*",
							"/dist/*",
							"/.nx/*",
							".next/*",
							".venv",
							"**/__pycache__/*",
							"**/.pytest_cache/*",
							"**/.ruff_cache/*",
						})
					),
				},
			},
			extensions = {
				fzf = {
					fuzzy = true,
					override_generic_sorter = true,
					override_file_sorter = true,
					case_mode = "smart_case",
				},
			},
		})

		-- Extensions
		telescope.load_extension("fzf")

		---@diagnostic disable-next-line: different-requires
		local finders = require("internal.telescope")
		local builtin = require("telescope.builtin")
		keybind_group("<leader>s", "Search"):register({
			keybind("n", "f", finders.find_files(), "Search files"),
			keybind("n", "l", finders.resume(), "Reopen last search"),
			keybind("n", "g", finders.live_grep(true), "Grep current buffer"),
			keybind("n", "G", finders.live_grep(false), "Grep search cwd"),
			keybind("n", "z", finders.fuzzy_live_grep(true), "Fuzzy find current buffer"),
			keybind("n", "Z", finders.fuzzy_live_grep(false), "Fuzzy find cwd"),
			keybind("n", "r", "<cmd>SearchReplaceSingleBufferOpen<cr>", "Replace"),
			keybind("v", "r", "<cmd>SearchReplaceSingleBufferVisualSelection<cr>", "Replace visual selection"),
			keybind_group("d", "diagnostics", {
				keybind("n", "a", function()
					builtin.diagnostics({ bufnr = 0 })
				end, "all (current buffer)"),
				keybind("n", "A", function()
					builtin.diagnostics({ bufnr = nil })
				end, "all"),
				keybind("n", "e", function()
					builtin.diagnostics({ bufnr = 0, severity = vim.diagnostic.severity.ERROR })
				end, "errors (current buffer)"),
				keybind("n", "E", function()
					builtin.diagnostics({ bufnr = nil, severity = vim.diagnostic.severity.ERROR })
				end, "errors"),
				keybind("n", "w", function()
					builtin.diagnostics({ bufnr = 0, severity = vim.diagnostic.severity.WARN })
				end, "warnings (current buffer)"),
				keybind("n", "W", function()
					builtin.diagnostics({ bufnr = nil, severity = vim.diagnostic.severity.WARN })
				end, "warnings"),
				keybind("n", "h", function()
					builtin.diagnostics({ bufnr = 0, severity = vim.diagnostic.severity.HINT })
				end, "hint (current buffer)"),
				keybind("n", "H", function()
					builtin.diagnostics({ bufnr = nil, severity = vim.diagnostic.severity.HINT })
				end, "hint"),
			}),
		})
	end)
plugin("nvim-telescope/telescope-fzf-native.nvim"):dependencies(telescope):build("make"):event("VeryLazy")
