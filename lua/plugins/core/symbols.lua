plugin("symbols"):event("DeferredUIEnter"):keymaps({
	k:map("n", "<M-s>", k:require("symbols").snacks_symbols(), "symbols"),
	k:map("n", "<M-S>", k:require("symbols").snacks_symbols_workspace(), "symbols"),
})
