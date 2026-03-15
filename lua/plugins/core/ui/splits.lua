plugin("smart-splits")
	:event("DeferredUIEnter")
	:opts({
		resize_mode = {
			silent = true,
			quit_key = "",
		},
	})
	:keymaps({
		k:map("n", "<M-C-L>", k:require("smart-splits").resize_right(), "resize right"),
		k:map("n", "<M-C-H>", k:require("smart-splits").resize_left(), "resize left"),
		k:map("n", "<M-C-K>", k:require("smart-splits").resize_up(), "resize up"),
		k:map("n", "<M-C-J>", k:require("smart-splits").resize_down(), "resize down"),
	})
