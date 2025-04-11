-- lsp("marksman")
plugin("render-markdown"):dep_on("nvim-treesitter"):ft({ "markdown", "codecompanion" }):opts({
	completions = { blink = { enabled = true } },
	file_types = {
		"markdown",
		"codecompanion",
	},
	code = {
		border = "thick",
	},
})
