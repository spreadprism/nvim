local ft = { "markdown", "opencode", "opencode_output" }
lsp("marksman"):cmd({ "marksman", "server" }):filetypes(ft)
linter(ft)
plugin("render-markdown"):ft(ft):opts({
	completions = { blink = { enabled = true } },
	file_types = ft,
	code = {
		border = "thick",
	},
})
