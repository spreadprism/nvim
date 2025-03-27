if nixCats("tmux") then
	keymapLoad({
		keymap("n", "<C-h>", "<cmd>TmuxNavigateLeft<CR>", "Navigate window left"),
		keymap("n", "<C-j>", "<cmd>TmuxNavigateDown<CR>", "Navigate window down"),
		keymap("n", "<C-k>", "<cmd>TmuxNavigateUp<CR>", "Navigate window up"),
		keymap("n", "<C-l>", "<cmd>TmuxNavigateRight<CR>", "Navigate window right"),
	})
end
