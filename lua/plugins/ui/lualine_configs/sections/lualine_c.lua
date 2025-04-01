return {
	{
		"copilot",
		separator = "",
		padding = { left = 1, right = 0 },
		color = function()
			local c = require("copilot-lualine")
			local ok, loading = pcall(c.is_loading)
			if ok and loading then
				return { fg = Colors.blue }
			else
				return { fg = "#565f89" }
			end
		end,
		show_loading = false,
		symbols = {
			status = {
				icons = {
					enabled = " ",
					sleep = " ", -- auto-trigger disabled
					disabled = " ",
					warning = " ",
					unknown = " ",
				},
			},
		},
	},
	require("plugins.ui.lualine_configs.components.dap"),
}
