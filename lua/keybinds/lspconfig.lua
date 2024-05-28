keybind_group("<leader>l", "lsp"):register({
	keybind("n", "i", "<cmd>LspInfo<cr>", "Show LSP information"),
	keybind("n", "r", "<cmd>LspRestart<cr>", "Restart language server"),
	keybind("n", "s", "<cmd>Neoconf show<cr>", "Show LSP settings"),
	keybind("n", "e", "<cmd>Neoconf<cr>", "Edit LSP settings"),
})
