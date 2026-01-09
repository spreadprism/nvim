-- TODO: implement
plugin("heirline"):event("UIEnter"):opts({
	statusline = {},
	winbar = {},
	statuscolumn = {},
	opts = {
		disable_winbar_cb = function(args)
			return true
		end,
	},
})
