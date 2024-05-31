keybind_group("<leader>t", "Tasks"):register({
	keybind("n", "r", "<cmd>OverseerRun<cr>", "Run task"),
	keybind("n", "i", "<cmd>OverseerInfo<cr>", "Open task runner info"),
	keybind("n", "e", "<cmd>OverseerToggle<cr>", "Tasks explorer"),
})
