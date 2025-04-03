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
		signcolumn = "number",
	},
})
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

kmap("n", "-", function()
	if vim.bo.filetype:match("^Neogit") then
		vim.cmd("q")
	end
	vim.cmd("Oil")
end, "Open filesystem")
kmap("n", "_", function()
	vim.cmd("Oil " .. vim.fn.getcwd())
end, "Open current working directory")
