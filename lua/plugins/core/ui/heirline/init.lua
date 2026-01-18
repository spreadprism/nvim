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
			opts = {
				disable_winbar_cb = function(args)
					return true
				end,
			},
		}
	end)
