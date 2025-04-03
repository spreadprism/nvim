if nixCats("tmux") then
	kmap("n", "<C-h>", kcmd("TmuxNavigateLeft"), "Navigate window left")
	kmap("n", "<C-j>", kcmd("TmuxNavigateDown"), "Navigate window down")
	kmap("n", "<C-k>", kcmd("TmuxNavigateUp"), "Navigate window up")
	kmap("n", "<C-l>", kcmd("TmuxNavigateRight"), "Navigate window right")
end
