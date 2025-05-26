plugin("neoscroll.nvim"):for_cat("core"):event_defer():opts({
	stop_eof = false,
	hide_cursor = false, -- BUG: cursor stays hidden
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
