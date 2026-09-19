local ft = {
	"crust_input",
	"crust_output",
}
plugin("crust")
	:event("DeferredUIEnter")
	:cmd("Crust")
	:opts({
		extension = { enabled = true },
	})
	:keymaps({
		k:map("n", "<M-p>", k:require("crust").open({ continue = true }), "open pi"),
		k:map("n", "<localleader>s", k:require("crust").sessions(), "session"):ft(ft),
		k:map("n", "<localleader>n", k:require("crust").new_session(), "new session"):ft(ft),
	})
