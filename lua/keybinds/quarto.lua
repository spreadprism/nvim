keybind_group("<leader>j", "notebook"):register({
	keybind("n", "e", "<cmd>QuartoSend<cr>", "Run cell"),
	keybind("n", "E", "<cmd>QuartoSendAll<cr>", "Run all cell"),
	keybind("v", "e", "<cmd>QuartoSendRange", "Run cell in range"),
	keybind("n", "i", "<cmd>MoltenInit<cr>", "Init Kernel"),
	keybind("n", "r", "<cmd>MoltenRestart<cr>", "Restart Kernel"),
	keybind("n", "o", ":noautocmd MoltenEnterOutput<cr>", "Show Output"),
})
