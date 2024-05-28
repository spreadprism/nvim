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
