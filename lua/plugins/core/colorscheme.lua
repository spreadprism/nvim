vim.cmd("colorscheme tokyonight-storm")
local transparent = require("transparent")
transparent.setup({
	exclude_groups = {
		"TelescopeSelection",
		"TelescopePreviewLine",
		"BlinkCmpMenuSelection",
		"BlinkCmpScrollBarGutter",
	},
})
transparent.clear_prefix("BlinkCmp")
transparent.clear_prefix("Telescope")
transparent.clear_prefix("Notify")
transparent.clear_prefix("OilVcsStatus")
transparent.clear_prefix("WhichKey")
transparent.clear_prefix("Float")
transparent.clear_prefix("NormalFloat")
