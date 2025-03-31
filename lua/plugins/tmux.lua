if nixCats("tmux") then
	keymapLoad({
		keymap("n", "<C-h>", keymapCmd("TmuxNavigateLeft"), "Navigate window left"),
		keymap("n", "<C-j>", keymapCmd("TmuxNavigateDown"), "Navigate window down"),
		keymap("n", "<C-k>", keymapCmd("TmuxNavigateUp"), "Navigate window up"),
		keymap("n", "<C-l>", keymapCmd("TmuxNavigateRight"), "Navigate window right"),
	})
end
