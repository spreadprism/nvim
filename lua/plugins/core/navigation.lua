plugin("hop"):event("DeferredUIEnter"):keymaps({
	k:map("nx", "<M-w>", k:require("hop").hint_words(), "hop to word"),
	k:map("nx", "<M-w>", k:require("hop").hint_lines(), "hop to line"):ft("oil"),
})

-- TODO: harpoon or alternatives (with row marks)
