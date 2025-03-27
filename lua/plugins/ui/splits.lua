plugin("smart-splits.nvim")
	:triggerUIEnter()
	:on_require("smart-splits")
	:opts({
		resize_mode = {
			silent = true,
			quit_key = "<ESC>",
		},
	})
	:keys({
		keymap("n", "<M-s>", function()
			require("smart-splits").start_resize_mode()
		end, "Start resize mode"),
		keymap("n", "<M-v>", keymapCmd("vsplit"), "Vertical split"),
		keymap("n", "<M-V>", keymapCmd("split"), "Vertical split"),
	})
