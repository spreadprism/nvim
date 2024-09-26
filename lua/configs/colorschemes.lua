local transparent = plugin("xiyaowong/transparent.nvim")
	:opts({
		extra_groups = { "Notify", "WhichKey", "Telescope" },
		exclude_groups = { "TelescopeSelection", "TelescopePreviewLine" },
	})
	:config(function()
		local transparent = require("transparent")
		transparent.setup({
			exclude_groups = { "TelescopeSelection", "TelescopePreviewLine" },
		})
		transparent.clear_prefix("LspInfoBorder")
		transparent.clear_prefix("Telescope")
		transparent.clear_prefix("Notify")
		transparent.clear_prefix("OilVcsStatus")
		transparent.clear_prefix("WhichKey")
		-- transparent.clear_prefix("Pmenu")
		transparent.clear_prefix("Float")
		transparent.clear_prefix("NormalFloat")
	end)

plugin("folke/tokyonight.nvim"):lazy(false):priority(1000):dependencies(transparent):config(function()
	require("tokyonight").setup({ style = "storm" })
	vim.cmd("colorscheme tokyonight")
end)
