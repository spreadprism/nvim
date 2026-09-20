local ft = {
	"markdown",
	"pi-chat-history",
	"pi-chat-prompt",
	"crust_input",
	"crust_output",
}
lsp("marksman"):cmd({ "marksman", "server" }):filetypes(ft)
linter(ft)
plugin("render-markdown"):ft(ft):opts({
	completions = { blink = { enabled = true } },
	file_types = ft,
	code = {
		border = "hide",
	},
	anti_conceal = {
		enabled = false,
	},
})
