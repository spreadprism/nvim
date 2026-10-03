local ft = {
	"crust_input",
	"crust_output",
}
plugin("crust")
	:event("DeferredUIEnter")
	:cmd("Crust")
	:opts({
		extension = { enabled = true },
		preload = { pi = true },
	})
	:after(function()
		require("internal.crust").register_tools()
	end)
	:keymaps({
		k:map("nx", "<M-c>", k:require("crust").smart(), "crust"),
		k:map("nx", "<M-p>", k:require("crust").quickprompt(), "quickprompt"),
		k:map("in", "<M-b>", k:require("crust").send_last_buffer(), "mention last buffer"):ft(ft),
		k:map("n", "<localleader>m", k:require("crust").model(), "model"):ft(ft),
		k:map("n", "<localleader>s", k:require("crust").sessions(), "session"):ft(ft),
		k:map("n", "<localleader>l", k:require("crust").session_last(), "last session"):ft(ft),
		k:map("n", "<localleader>n", k:require("crust").new_session(), "new session"):ft(ft),
		k:map("n", "<localleader>r", k:require("crust").rename_session(), "rename session"):ft(ft),
	})
