plugin("symbols")
	:event("DeferredUIEnter")
	:keymaps({
		k:map("n", "<M-s>", k:require("snacks.picker").symbols({ layout = "right" }), "symbols"),
		k:map(
			"n",
			"<M-S>",
			k:require("snacks.picker").symbols_workspace({ layout = "ivy_split" }),
			"symbols (workspace)"
		),
	})
	:dep_on("snacks")
