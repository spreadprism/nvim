local ft = { "markdown", "codecompanion" }
lsp("marksman"):cmd("marksman", "server"):ft(unpack(ft))
plugin("render-markdown"):dep_on("nvim-treesitter"):ft({ "markdown", "codecompanion" }):opts({
	completions = { blink = { enabled = true } },
	file_types = ft,
	code = {
		border = "thick",
	},
})
formatter(ft, "prettier")
