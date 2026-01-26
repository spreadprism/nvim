return {
	static = {
		get_icon = require("nvim-web-devicons").get_icon,
		get_icon_filetype = require("nvim-web-devicons").get_icon_by_filetype,
	},
	init = function(self)
		self.buf = vim.api.nvim_get_current_buf()
		self.win = vim.api.nvim_get_current_win()
		self.ft = vim.bo[self.buf].ft
	end,
	{ provider = " " },
	require("internal.ui.winbar.location"),
}
