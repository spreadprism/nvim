local oil = plugin("oil")
	:opts({
		use_default_keymaps = false,
		experimental_watch_for_changes = true,
		skip_confirm_for_simple_edits = true,
		keymaps = {
			["g?"] = "actions.show_help",
			["<CR>"] = "actions.select",
			["<M-CR>"] = "actions.select_vsplit",
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

plugin("oil-vcs")
	:dep_on(oil)
	:opts({
		symbols_on_dir = false,
	})
	:lazy(false)
