plugin("treesj")
	:cmd({ "TSJSplit", "TSJJoin" })
	:keymaps({
		k:map("n", "gs", k:cmd("TSJSplit"), "split"),
		k:map("n", "gj", k:cmd("TSJJoin"), "join"),
	})
	:opts({
		use_default_keymaps = false,
	})

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
		k:map("v", "<M-e>", k:cmd(""), "Multi-edits"),
	})
