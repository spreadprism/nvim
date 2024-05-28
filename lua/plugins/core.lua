plugin("nvim-lua/plenary.nvim")
plugin("nvim-tree/nvim-web-devicons"):optional(true):opts({
	default = true,
	strict = false,
	override_by_filename = require("icons.filename"),
	override_by_extension = require("icons.extension"),
})
