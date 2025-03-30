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
		keymap("n", "<M-C-L>", function()
			require("smart-splits").resize_right()
		end, "resize right"),
		keymap("n", "<M-C-H>", function()
			require("smart-splits").resize_left()
		end, "resize left"),
		keymap("n", "<M-C-K>", function()
			require("smart-splits").resize_up()
		end, "resize up"),
		keymap("n", "<M-C-J>", function()
			require("smart-splits").resize_down()
		end, "resize down"),
		keymap("n", "<M-v>", keymapCmd("vsplit"), "Vertical split"),
		keymap("n", "<M-V>", keymapCmd("split"), "Vertical split"),
	})
