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
			sources = {
				files = {
					layout = {
						preset = "select",
					},
				},
				grep = {
					layout = {
						preset = "telescope",
					},
				},
				lines = {
					layout = {
						preset = "ivy_split",
					},
				},
				lsp_symbols = {
					layout = {
						preset = "right",
					},
				},
				lsp_workspace_symbols = {
					layout = {
						preset = "telescope",
					},
				},
			},
		},
	})
	:allow_again(vim.env.PROF)
	:keymaps({
		k:map("n", "<leader><leader>", k:require("snacks.picker").files(), "find files"):hidden(),
		k:map("n", "<M-g>", k:require("snacks.picker").grep(), "grep project"),
		k:map("n", "<M-f>", k:require("snacks.picker").lines(), "find in buffer"),
		k:group("find", "<leader>f", {
			k:map("n", "h", k:require("snacks.picker").highlights(), "highlights"),
			k:map("n", "l", k:require("snacks.picker").resume(), "reopen last search"),
		}),
	})
	:lazy(false)
