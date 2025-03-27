plugin("vim-startuptime")
	:for_cat("core")
	:cmd("StartupTime")
	:before(function(_)
		vim.g.startuptime_event_width = 0
		vim.g.startuptime_tries = 10
		vim.g.startuptime_exe_path = nixCats.packageBinPath
	end)
	:after(nil)
