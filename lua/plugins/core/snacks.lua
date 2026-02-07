plugin("snacks")
	:opts({
		image = {
			enabled = true,
		},
		inputs = {
			enabled = true,
		},
		picker = {
			main = {
				file = false,
			},
			enabled = true,
			matcher = {
				frecency = true,
			},
		},
	})
	:allow_again(vim.env.PROF)
	:keymaps({
		k:map(
			"n",
			"<leader><leader>",
			k:require("snacks.picker").files({ layout = { preset = "select" } }),
			"find files"
		):hidden(),
		k:map("n", "<M-g>", k:require("snacks.picker").grep(), "grep project"),
		k:map("n", "<M-f>", k:require("snacks.picker").lines({ layout = { preset = "ivy_split" } }), "find in buffer"),
		k:map(
			"n",
			"<M-s>",
			k:require("snacks.picker").lsp_symbols({ layout = { preset = "right" } }),
			"find in buffer"
		),
		k:group("find", "<leader>f", {
			k:map("n", "h", k:require("snacks.picker").highlights(), "highlights"),
			k:map("n", "l", k:require("snacks.picker").resume(), "lsp references"),
		}),
	})
	:lazy(false)
