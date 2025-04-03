plugin("vim-startuptime")
	:for_cat("core")
	:cmd("StartupTime")
	:set_g_options({
		startuptime_event_width = 0,
		startuptime_tries = 10,
		startuptime_exe_path = nixCats.packageBinPath,
	})
	:config(false)
