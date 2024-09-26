keybind_group("<leader>g", "git"):register({
  keybind("n", "g", "<cmd>Neogit<cr>", "Open Neogit"),
	keybind("n", "d", function()
		vim.cmd("Barbecue hide")
		vim.cmd("DiffviewOpen")
	end, "Open Diff view"),
	keybind("n", "q", function()
		vim.cmd("DiffviewClose")
		vim.cmd("Barbecue show")
	end, "Close Diff view"),
})
