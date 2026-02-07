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
			actions = {
				git_log = function(picker, item)
					vim.print(item)
				end,
			},
		},
	})
	:allow_again(vim.env.PROF)
	:keymaps({
		k:map("n", "<leader><leader>", k:require("snacks.picker").files(), "find files"):hidden(),
		k:group("find", "<leader>f", {
			k:map("n", "f", k:require("snacks.picker").files(), "files"),
			k:map("n", "h", k:require("snacks.picker").highlights(), "highlights"),
		}),
	})
	:lazy(false)
