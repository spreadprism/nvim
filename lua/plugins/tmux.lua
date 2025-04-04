plugin("tmux-navigation")
	:for_cat("tmux")
	:on_require("nvim-tmux-navigation")
	:keys({
		kmap("n", "<C-h>", kcmd("NvimTmuxNavigateLeft"), "Navigate window left"),
		kmap("n", "<C-j>", kcmd("NvimTmuxNavigateDown"), "Navigate window down"),
		kmap("n", "<C-k>", kcmd("NvimTmuxNavigateUp"), "Navigate window up"),
		kmap("n", "<C-l>", kcmd("NvimTmuxNavigateRight"), "Navigate window right"),
	})
	:cmd({
		"NvimTmuxNavigateLeft",
		"NvimTmuxNavigateDown",
		"NvimTmuxNavigateUp",
		"NvimTmuxNavigateRight",
	})
