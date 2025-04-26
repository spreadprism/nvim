plugin("vim-startuptime"):cmd("StartupTime"):config(function()
	vim.g.startuptime_event_width = 0
	vim.g.startuptime_tries = 10
	vim.g.startuptime_exe_path = nixCats.packageBinPath
end)
