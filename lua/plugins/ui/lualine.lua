require("lualine").setup({
	theme = "auto",
	globalstatus = true,
	disabled_filetypes = { statusline = { "dashboard", "alpha" } },
	-- INFO: prevent telescope from stealing focus
	ignore_focus = { "TelescopePrompt" },
	sections = require("plugins.ui.lualine_configs.sections"),
	winbar = require("plugins.ui.lualine_configs.winbar"),
	options = {
		refresh = {
			winbar = 1,
		},
	},
})
