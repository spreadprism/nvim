-- Exit keybinds
keybind({ "i", "v" }, ";;", "<Esc>", "Escape iv"):register()
keybind("t", ";;", "<C-\\><C-n>", "Escape term"):register()
keybind("n", "<C-q>", "<cmd>q<CR>", "Quit"):register()

-- INFO: Open stuff
keybind_group("<leader>o", "Open"):register({
	keybind("n", "p", "<cmd>Lazy<cr>", "Open plugin manager"),
	keybind("n", "P", "<cmd>Mason<cr>", "Open tools manager"),
	keybind("n", "d", "<cmd>Dashboard<cr>", "Open dashboard"),
})

-- INFO: Code Navigation
keybind({ "n", "v" }, "L", "g_", "Move cursor to last non-whitespace character"):register()
keybind({ "n", "v" }, "H", "^", "Move cursor to last non-whitespace character"):register()

-- INFO: Code manipulation
keybind("v", "Y", '"+y', "Yank to clipboard"):register()
keybind("n", "<A-J>", "Vyp", "Duplicate line down"):register()
keybind("n", "<A-K>", "VyP", "Duplicate line up"):register()
keybind("v", "<A-J>", "yp", "Duplicate line down"):register()
keybind("v", "<A-K>", "yP", "Duplicate line up"):register()
keybind("n", "<A-o>", "o<ESC>k", "Insert line under"):register()
keybind("n", "<A-O>", "O<ESC>k", "Insert line over"):register()
keybind("v", "<Tab>", ">gv", "Insert table"):register()
keybind("v", "<S-Tab>", "<gv", "Remove tab"):register()
