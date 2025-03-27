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
		-- winbar = " %{v:lua.require('internal.oil').winbar()}",
		signcolumn = "number",
	},
})

keymapLoad({
	keymap("n", "-", function()
		if vim.bo.filetype:match("^Neogit") then
			vim.cmd("q")
		end
		vim.cmd("Oil")
	end, "Open filesystem"),
	keymap("n", "_", function()
		vim.cmd("Oil " .. vim.fn.getcwd())
	end, "Open current working directory"),
})
