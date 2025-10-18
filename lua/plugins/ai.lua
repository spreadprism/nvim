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

plugin("opencode")
	:dep_on("snacks")
	:on_require("opencode")
	:event_defer()
	:opts({
		preferred_picker = "snacks",
		preferred_completion = "blink",
		default_global_keymaps = false,
	})
	:keys(kgroup("<leader>a", "assistant", {}, {
		kmap("n", "a", klazy("opencode.api").open_input(), "open input"),
		kmap("n", "A", klazy("opencode.api").open_input_new_session(), "open input (new session)"),
	}))
