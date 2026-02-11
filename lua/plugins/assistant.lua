plugin("copilot"):event("DeferredUIEnter"):opts({
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
	:dep_on({
		"snacks",
		"blink.cmp",
	})
	:event("DeferredUIEnter")
	:opts({
		preferred_picker = "snacks",
		preferred_completion = "blink",
		default_global_keymaps = false,
	})
	:keymaps({
		k:group("assistant", "<leader>a", {
			k:map("n", "a", k:require("opencode.api").open_input(), "open "),
			k:map("nv", "p", k:require("opencode.api").quick_chat(), "prompt"),
		}),
	})
