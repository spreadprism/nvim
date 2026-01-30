local statusline = {
	init = function(self)
		self.bufnr = vim.api.nvim_get_current_buf()
	end,
	static = {
		mode_color = function()
			local mode_colors = {
				n = colors.blue,
				i = colors.green,
				v = colors.purple,
				V = colors.purple,
				["\22"] = colors.purple,
				c = colors.orange,
				s = colors.purple,
				S = colors.purple,
				["\19"] = colors.purple,
				R = colors.orange,
				r = colors.orange,
				["!"] = colors.red,
				t = colors.red,
			}
			return mode_colors[vim.fn.mode()]
		end,
	},
	require("internal.ui.statusline.mode"),
	require("internal.ui.statusline.git"),
	{ provider = "%=" },
	require("internal.ui.statusline.tab"),
}

return statusline
