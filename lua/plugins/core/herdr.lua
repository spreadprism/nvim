plugin("herdr")
	:event("DeferredUIEnter")
	:enabled(vim.env.HERDR_ENV)
	:opts({
		set_keymaps = false,
		helper = "herdr-navigator",
	})
	:keymaps({
		k:map("n", "<C-Down>", k:cmd("HerdrNavigateDown"), "navigate down"),
		k:map("n", "<C-Up>", k:cmd("HerdrNavigateUp"), "navigate up"),
		k:map("n", "<C-Left>", k:cmd("HerdrNavigateLeft"), "navigate left"),
		k:map("n", "<C-Right>", k:cmd("HerdrNavigateRight"), "navigate right"),
	})
