-- INFO: Even if not lazyloaded, we don't save any time on the bar display
plugin("lualine-nvim"):dep_on("overseer"):config(function()
	require("lualine").setup({
		options = {
			theme = "auto",
			globalstatus = true,
			ignore_focus = { "TelescopePrompt" },
			disabled_filetypes = {
				statusline = {},
				winbar = { "kulala_ui", "dbee" },
			},
		},
		sections = require("plugins.ui.lualine.sections"),
		winbar = require("plugins.ui.lualine.winbar"),
		inactive_winbar = require("plugins.ui.lualine.winbar"),
		extensions = {
			require("plugins.ui.lualine.extensions.nvim-dap-ui"),
			{
				filetypes = { "gitsigns-blame", "NeogitCommitView", "OverseerList", "undotree", "neotest-summary" },
				winbar = {},
			},
		},
	})
end)
