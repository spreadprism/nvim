keybind("n", "-", "<cmd>Oil<cr>", "Open directory"):register()
keybind("n", "_", function()
	vim.cmd("Oil " .. vim.fn.getcwd())
end, "Open directory"):register()
