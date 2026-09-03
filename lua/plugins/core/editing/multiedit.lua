plugin("live-command")
	:event("DeferredUIEnter")
	:opts({
		commands = {
			Norm = { cmd = "norm" },
		},
	})
	:after(function()
		vim.cmd("cnoreabbrev norm Norm")
	end)
	:keymaps({
		k:map("v", "<M-e>", function()
			vim.cmd(':call feedkeys(": Norm ")')
		end, "Multi-edit"),
	})
