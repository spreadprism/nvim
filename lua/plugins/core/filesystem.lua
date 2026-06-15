local oil = plugin("oil")
	:opts({
		use_default_keymaps = false,
		experimental_watch_for_changes = true,
		skip_confirm_for_simple_edits = true,
		keymaps = {
			["g?"] = "actions.show_help",
			["<CR>"] = "actions.select",
			["<S-CR>"] = "actions.select_vsplit",
			["<S-Tab>"] = "actions.select_tab",
			["K"] = "actions.preview",
			["-"] = "actions.parent",
			["<C-q>"] = "actions.close",
			["_"] = "actions.open_cwd",
			["."] = "actions.cd",
		},
		view_options = {
			show_hidden = true,
			natural_order = false,
		},
		win_options = {
			signcolumn = "number",
		},
		confirmation = {
			border = "rounded",
		},
	})
	:keymaps({
		k:map("n", "-", k:cmd("Oil"), "Open filesystem"),
		k:map("n", "_", function()
			vim.cmd("Oil " .. vim.fn.getcwd())
		end, "Open current working directory"),
	})
	:on_highlights(function(highlights, _)
		highlights.OilDirHidden = "OilDir"
		highlights.OilFileHidden = "OilFile"
	end)
	:lazy(false)

plugin("oil-git"):dep_on(oil):lazy(false):opts({
	show_directory_symbols = false,
	show_ignored_files = true,
	show_ignored_directories = false, -- BUG: https://github.com/malewicz1337/oil-git.nvim/issues/11
	symbols = {
		file = {
			added = "+",
			modified = "~",
			untracked = "?",
			ignored = "!",
			deleted = "-",
			renamed = "→",
			conflict = "!",
		},
	},
	highlights = {
		OilGitAdded = { fg = "#9ece6a" },
		OilGitModified = { fg = "#e0af68" },
		OilGitRenamed = { fg = "#cba6f7" },
		OilGitUntracked = { fg = "#7aa2f7" },
		OilGitIgnored = { fg = "#565F89" },
		OilGitDeleted = { fg = "#f7768e" },
		OilGitConflict = { fg = "#f7768e" },
	},
})
