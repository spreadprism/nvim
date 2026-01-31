plugin("hop"):event("DeferredUIEnter"):keymaps({
	k:map("nx", "<M-w>", k:require("hop").hint_words(), "hop to word"),
	k:map("nx", "<M-w>", k:require("hop").hint_lines(), "hop to line"):ft("oil"),
	k:map("nx", "f", k:require("internal.plugins.hop").hop_char_line(), "hop char l-AC"),
	k:map("nx", "F", k:require("internal.plugins.hop").hop_char_line(false), "hop char l-BC"),
	k:map("nx", "t", k:require("internal.plugins.hop").hop_char_line(true, -1), "hop before char l-AC"),
	k:map("nx", "T", k:require("internal.plugins.hop").hop_char_line(false, 1), "hop after char l-BC"),
})

-- TODO: harpoon or alternatives (with row marks)
