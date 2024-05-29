keybind_group("<leader>st", "search tags"):register({
	keybind("n", "a", "<cmd>TodoTelescope<cr>", "All tags"),
	keybind("n", "t", "<cmd>TodoTelescope keywords=TODO<cr>", "Todo"),
	keybind("n", "i", "<cmd>TodoTelescope keywords=NOTE<cr>", "Info"),
	keybind("n", "b", "<cmd>TodoTelescope keywords=BUG<cr>", "Bug"),
})
