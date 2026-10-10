plugin("gitsigns")
	:cmd("Gitsigns")
	:event("BufEnter")
	:opts({
		signcolumn = true,
		numhl = true,
		current_line_blame_opts = {
			delay = 10,
		},
		preview_config = {
			border = "rounded",
		},
		current_line_blame_formatter = "<author>, <author_time:%R>",
		on_attach = function(bufnr)
			k:opts({
				k:map("n", "<M-b>", k:cmd("Gitsigns toggle_current_line_blame"), "Toggle line blame"),
				-- k:map("n", "<M-B>", k:cmd("Gitsigns blame"), "open blame window"),
			})
				:buffer(bufnr)
				:add()
		end,
	})
	:after(function()
		vim.schedule(function()
			vim.cmd("redrawstatus!")
		end)
	end)
