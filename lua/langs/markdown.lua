local ft = {
	"markdown",
	"pi-chat-history",
	"pi-chat-prompt",
}
lsp("marksman"):cmd({ "marksman", "server" }):filetypes(ft)
linter(ft)
plugin("render-markdown"):ft(ft):opts({
	completions = { blink = { enabled = true } },
	file_types = ft,
	code = {
		border = "hide",
	},
})
