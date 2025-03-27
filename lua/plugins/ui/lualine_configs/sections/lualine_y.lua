return {
	{
		"tabs",
		mode = 0,
		separators = "",
		cond = function()
			return #vim.api.nvim_list_tabpages() > 1
		end,
		use_mode_colors = true,
		symbols = {
			modified = " " .. Symbols.modified,
		},
	},
}
