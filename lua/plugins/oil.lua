local oil = plugin("stevearc/oil.nvim"):lazy(false):dependencies("nvim-tree/nvim-web-devicons"):opts({
	use_default_keymaps = false,
	experimental_watch_for_changes = true,
	skip_confirm_for_simple_edits = true,
	keymaps = {
		["g?"] = "actions.show_help",
		["<CR>"] = "actions.select",
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
		winbar = " %{v:lua.require('utils.oil').winbar()}",
	},
})
-- TODO: Add symbols and hl groups for oil-vcs-status
plugin("SirZenith/oil-vcs-status")
	:dependencies(oil:plugin_key())
	:event("VeryLazy")
	:opts({
		status_symbol = {
			["added"] = "",
			["copied"] = "󰆏",
			["deleted"] = "",
			["ignored"] = "",
			["modified"] = "",
			["renamed"] = "",
			["typechanged"] = "󰉺",
			["unmodified"] = " ",
			["unmerged"] = "",
			["untracked"] = "",
			["external"] = "",

			["upstream_added"] = "󰈞",
			["upstream_copied"] = "󰈢",
			["upstream_deleted"] = "",
			["upstream_ignored"] = " ",
			["upstream_modified"] = "󰏫",
			["upstream_renamed"] = "",
			["upstream_typechanged"] = "󱧶",
			["upstream_unmodified"] = " ",
			["upstream_unmerged"] = "",
			["upstream_untracked"] = " ",
			["upstream_external"] = "",
		},
		status_hl_group = {
			["modified"] = "OilVcsStatusIgnored",
		},
	})
	:enabled(false)
