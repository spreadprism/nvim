plugin("nvim-surround")
	:event("DeferredUIEnter")
	:opts({
		keymaps = {
			visual = "sa",
		},
	})
	:keymaps({
		k:map("n", "sa", "<Plug>(nvim-surround-normal)", "add surrounding pair"),
	})
