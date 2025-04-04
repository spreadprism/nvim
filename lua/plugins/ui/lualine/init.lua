plugin("copilot-lualine"):on_plugin("lualine-nvim"):config(false)
-- INFO: Even if not lazyloaded, we don't save any time on the bar display
plugin("lualine-nvim"):dep_on("overseer.nvim"):config(function()
	internal.load_all("plugins.ui.lualine.components")
	require("lualine").setup({
		options = {
			theme = "auto",
			globalstatus = true,
			disabled_filetypes = {
				statusline = {
					"dashboard",
					"alpha",
				},
				winbar = {
					"kulala-ui",
					"dap-view",
				},
			},
			ignore_focus = { "TelescopePrompt" },
			refresh = {
				winbar = 1,
			},
		},
		sections = require("plugins.ui.lualine.sections"),
		winbar = require("plugins.ui.lualine.winbar"),
		inactive_winbar = require("plugins.ui.lualine.winbar"),
		extensions = {},
	})
end)
