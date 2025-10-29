local ft = { "markdown", "codecompanion", "opencode", "opencode_output" }
lsp("marksman"):cmd({ "marksman", "server" }):ft(unpack(ft))
plugin("render-markdown"):dep_on("nvim-treesitter"):ft(unpack(ft)):opts({
	completions = { blink = { enabled = true } },
	file_types = ft,
	code = {
		border = "thick",
	},
})
formatter(ft, "prettierd")
