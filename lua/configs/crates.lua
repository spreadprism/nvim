require("crates").setup({
	lsp = {
		enabled = true,
		on_attach = function(client, bufnr)
			-- the same on_attach function as for your other lsp's
		end,
		actions = true,
		completion = true,
		hover = true,
	},
	popup = {
		border = "rounded",
	},
	completion = {
		crates = {
			enabled = true,
			max_results = 8,
			min_chars = 3,
		},
		-- cmp = {
		-- 	enabled = true,
		-- },
	},
})
