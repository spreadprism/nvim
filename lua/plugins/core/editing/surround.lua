plugin("nvim-surround"):event("DeferredUIEnter"):keymaps({
	k:map("n", "sa", "<Plug>(nvim-surround-normal)", "add surrounding pair"),
	k:map("x", "sa", "<Plug>(nvim-surround-visual)", "surround selection"),
})
