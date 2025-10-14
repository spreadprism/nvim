if not nixCats("ai") then
	return
end

plugin("copilot"):event_defer():on_require("copilot"):opts({
	filetypes = {
		markdown = true,
		yaml = true,
	},
	suggestion = {
		enabled = true,
		auto_trigger = false,
		keymap = {
			accept = "<M-a>",
			dismiss = "<M-d>",
			next = false,
		},
	},
	panel = { enabled = false },
})
