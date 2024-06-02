keybind_group("<leader>u", "Unit testing"):register({
	keybind("n", "e", "<cmd>Neotest summary<cr>", "Tests explorer"),
	keybind("n", "c", "<CMD>lua require('neotest').run.run()<CR>", "Test current function"),
	keybind("n", "f", "<CMD>lua require('neotest').run.run(vim.fn.expand('%'))<CR>", "Test current file"),
	keybind("n", "p", "<CMD>lua require('neotest').run.run(vim.fn.getcwd())<CR>", "Test current project"),
})
