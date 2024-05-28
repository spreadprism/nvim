local ll_utils = require("utils.lualine_utils")
return {
	{
		"filetype",
		icon_only = true,
		separator = "",
		padding = { left = 1, right = 1 },
		cond = ll_utils.display_file,
	},
	{
		"filename",
		path = 0,
		separator = "",
		padding = { left = 0, right = 1 },
		symbols = { modified = "󱇧", readonly = "󰷊", unnamed = "" },
		cond = ll_utils.display_file,
	},
}
