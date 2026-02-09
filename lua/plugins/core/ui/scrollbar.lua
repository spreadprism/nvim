-- TODO: https://github.com/petertriho/nvim-scrollbar
plugin("scrollbar"):event("UIEnter"):opts({
	hide_if_all_visible = true,
	handlers = {
		cursor = false,
		gitsigns = true,
	},
})
