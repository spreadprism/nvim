local oil = plugin("stevearc/oil.nvim"):lazy(false):dependencies("nvim-tree/nvim-web-devicons"):config(function()
	require("oil").setup({
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
			winbar = " %{v:lua.require('internal.oil').winbar()}",
			signcolumn = "number",
		},
	})
	keybind("n", "-", "<cmd>Oil<cr>", "Open directory"):register()
	keybind("n", "_", function()
		vim.cmd("Oil " .. vim.fn.getcwd())
	end, "Open directory"):register()
end)
-- TODO: Add symbols and hl groups for oil-vcs-status
plugin("SirZenith/oil-vcs-status"):dependencies(oil):lazy(false):config(function()
	local status_const = require("oil-vcs-status.constant.status")

	local StatusType = status_const.StatusType
	require("oil-vcs-status").setup({
		status_symbol = {
			[StatusType.Added] = "",
			[StatusType.Copied] = "󰆏",
			[StatusType.Deleted] = "",
			[StatusType.Ignored] = "",
			[StatusType.Modified] = "",
			[StatusType.Renamed] = "",
			[StatusType.TypeChanged] = "󰉺",
			[StatusType.Unmodified] = " ",
			[StatusType.Unmerged] = "",
			[StatusType.Untracked] = "",
			[StatusType.External] = "",

			[StatusType.UpstreamAdded] = "󰈞",
			[StatusType.UpstreamCopied] = "󰈢",
			[StatusType.UpstreamDeleted] = "",
			[StatusType.UpstreamIgnored] = " ",
			[StatusType.UpstreamModified] = "󰏫",
			[StatusType.UpstreamRenamed] = "",
			[StatusType.UpstreamTypeChanged] = "󱧶",
			[StatusType.UpstreamUnmodified] = " ",
			[StatusType.UpstreamUnmerged] = "",
			[StatusType.UpstreamUntracked] = " ",
			[StatusType.UpstreamExternal] = "",
		},
	})
end)
