keybind_group("<leader>g", "git"):register({
	keybind("n", "d", "<cmd>DiffviewOpen<cr>", "Open Diff view"),
	keybind("n", "q", "<cmd>DiffviewClose<cr>", "Close Diff view"),
})
