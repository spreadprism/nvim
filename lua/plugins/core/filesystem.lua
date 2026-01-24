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
		k:map("n", "-", k.act:cmd("Oil"), "Open filesystem"),
		k:map("n", "_", function()
			vim.cmd("Oil " .. vim.fn.getcwd())
		end, "Open current working directory"),
	})
	:lazy(false)

plugin("oil-vcs")
	:dep_on(oil)
	:opts(function()
		local status = require("oil-vcs").Status
		return {
			symbols_on_dir = false,
			symbols = {
				[status.Added] = Symbols.added,
				[status.Modified] = Symbols.modified,
				[status.Untracked] = Symbols.untracked,
				[status.Ignored] = "",
				[status.Deleted] = Symbols.deleted,
				[status.Renamed] = Symbols.moved,
				[status.Conflict] = Symbols.conflict,
				[status.PartialStage] = Symbols.partial_stage,
			},
		}
	end)
	:lazy(false)
