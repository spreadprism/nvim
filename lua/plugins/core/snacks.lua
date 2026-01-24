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
		k:map("n", "<leader><leader>", k.act:lazy("snacks.picker").files(), "find files"):hidden(),
		k:group("find", "<leader>f", {
			k:map("n", "f", k.act:lazy("snacks.picker").files(), "files"),
			k:map("n", "h", k.act:lazy("snacks.picker").highlights(), "highlights"),
		}),
	})
	:lazy(false)
