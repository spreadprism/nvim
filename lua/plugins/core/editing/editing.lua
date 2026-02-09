-- TODO: live-command
plugin("treesj")
	:cmd({ "TSJSplit", "TSJJoin" })
	:keymaps({
		k:map("n", "gs", k:cmd("TSJSplit"), "split"),
		k:map("n", "gj", k:cmd("TSJJoin"), "join"),
	})
	:opts({
		use_default_keymaps = false,
	})
