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
	:allow_again(function()
		return vim.env.PROF
	end)
	:kmap("n", "<leader><leader>", klazy("snacks.picker").files(), "find files")
	:kgroup("find", "<leader>f", {
		kmap("n", "f", klazy("snacks.picker").files(), "files"),
		kmap("n", "h", klazy("snacks.picker").highlights(), "highlights"),
	})
	:lazy(false)
