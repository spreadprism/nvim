plugin("neogen")
	:event("DeferredUIEnter")
	:opts({
		snippet_engine = "luasnip",
	})
	:keymaps(k:map("n", "gca", k:require("neogen").generate(), "annotate"))
