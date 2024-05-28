plugin("zbirenbaum/copilot.lua"):event("VeryLazy"):opts({
	suggestion = {
		enabled = true,
		auto_trigger = false,
		keymap = {
			accept = "<M-a>",
			dismiss = "<M-d>",
			next = "<M-l>",
		},
	},
	panel = { enabled = false },
})
