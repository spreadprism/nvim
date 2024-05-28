require("lualine").setup({
	options = {
		theme = "auto",
		globalstatus = true,
		disabled_filetypes = { statusline = { "dashboard", "alpha" } },
		-- prevent telescope from stealing focus
		ignore_focus = { "TelescopePrompt", "Mason" },
	},
	sections = require("utils.lualine_utils").generate_config("sections"),
	inactive_sections = require("utils.lualine_utils").generate_config("inactive_sections"),
})
