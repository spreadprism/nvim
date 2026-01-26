plugin("heirline")
	:event("UIEnter")
	:dep_on(plugin("heirline-components"))
	:before(function()
		vim.o.laststatus = 3
	end)
	:opts(function()
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
