plugin("trouble.nvim")
	:on_require("trouble")
	:cmd("Trouble")
	:opts({
		auto_preview = false,
		focus = true,
	})
	:keys({
		keymap("n", "<M-t>", keymapCmd("Trouble diagnostics toggle filter.buf=0")),
		keymap("n", "<M-T>", keymapCmd("Trouble diagnostics toggle")),
	})
