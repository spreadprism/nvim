-- require("plugins.overseer")
plugin("copilot-lualine"):on_plugin("lualine-nvim"):config(false)
plugin("lualine-nvim"):defer():config(function()
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
		sections = require("plugins.ui.lualine_configs.sections"),
		winbar = require("plugins.ui.lualine_configs.winbar"),
		inactive_winbar = require("plugins.ui.lualine_configs.winbar"),
		extensions = {
			require("internal.winbar_components.dapui"),
		},
	})
end)
