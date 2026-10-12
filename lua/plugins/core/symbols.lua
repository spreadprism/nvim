plugin("symbols")
	:event("DeferredUIEnter")
	:keymaps({
		k:map("n", "<M-s>", k:require("snacks.picker").symbols(), "symbols"),
		k:map("n", "<M-S>", k:require("snacks.picker").symbols_workspace(), "symbols (workspace)"),
	})
	:dep_on("snacks")
