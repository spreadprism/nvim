-- TODO: quicker
plugin("quicker")
	:event("DeferredUIEnter")
	:keymaps(k:map("n", "<M-q>", k:require("quicker").toggle(), "toggle quickfix"))
