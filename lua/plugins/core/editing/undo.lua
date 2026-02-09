plugin("undotree")
	:event("DeferredUIEnter")
	:opts({
		position = "right",
	})
	:keymaps(k:map("n", "<M-u>", k:require("undotree").toggle(), "toggle undotree"))
