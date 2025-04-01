require("plugins.overseer")
require("copilot-lualine")
require("lualine").setup({
	options = {
		theme = "auto",
		globalstatus = true,
		disabled_filetypes = { statusline = { "dashboard", "alpha" } },
		ignore_focus = { "TelescopePrompt" },
		refresh = {
			winbar = 1,
		},
	},
	sections = require("plugins.ui.lualine_configs.sections"),
	winbar = require("plugins.ui.lualine_configs.winbar"),
	inactive_winbar = require("plugins.ui.lualine_configs.winbar"),
	extensions = {
		require("internal.winbar_components.dapui"),
	},
})
