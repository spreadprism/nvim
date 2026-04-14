plugin("startuptime")
	:opts(false)
	:cmd("StartupTime")
	:keymaps({
		k:map("n", "<leader>==", k:cmd("tab StartupTime"), "startup time"),
	})
	:before(function()
		vim.g.startuptime_exe_path = "nvim"
	end)
