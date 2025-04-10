plugin("neoscroll.nvim"):for_cat("core"):event_defer():opts({
	stop_eof = false,
	hide_cursor = true,
	pre_hook = function()
		vim.opt.eventignore:append({
			"WinScrolled",
			"CursorMoved",
		})
	end,
	post_hook = function()
		vim.opt.eventignore:remove({
			"WinScrolled",
			"CursorMoved",
		})
	end,
})
