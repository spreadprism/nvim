plugin("heirline")
	:event("UIEnter")
	:dep_on({
		plugin("heirline-components"),
		"gitsigns",
	})
	:before(function()
		vim.o.laststatus = 3
	end)
	:opts(function()
		local heirline = require("heirline")
		local heirline_components = require("heirline-components.all")

		heirline_components.init.subscribe_to_events()
		heirline.load_colors(heirline_components.hl.get_colors())
		return {
			statusline = require("internal.ui.statusline"),
			statuscolumn = require("internal.ui.statuscolumn"),
			winbar = require("internal.ui.winbar"),
			opts = {
				disable_winbar_cb = function(args)
					return require("heirline.conditions").buffer_matches({
						buftype = { "nofile", "prompt", "help", "quickfix" },
						filetype = { "^git.*", "fugitive", "Trouble", "dashboard", "^$" },
					}, args.buf)
				end,
			},
		}
	end)
