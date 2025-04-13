plugin("smart-splits.nvim")
	:event_defer()
	:on_require("smart-splits")
	:opts({
		resize_mode = {
			silent = true,
			quit_key = "",
		},
	})
	:keys({
		kmap("n", "<M-C-L>", function()
			require("smart-splits").resize_right()
		end, "resize right"),
		kmap("n", "<M-C-H>", function()
			require("smart-splits").resize_left()
		end, "resize left"),
		kmap("n", "<M-C-K>", function()
			require("smart-splits").resize_up()
		end, "resize up"),
		kmap("n", "<M-C-J>", function()
			require("smart-splits").resize_down()
		end, "resize down"),
	})
