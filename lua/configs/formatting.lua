vim.api.nvim_create_autocmd({ "BufWritePost" }, {
	command = "FormatWriteLock",
})

require("formatter").setup({
	filetype = {
		["*"] = {
			require("formatter.filetypes.any").remove_trailing_whitespace,
		},
		javascript = {
			require("formatter.filetypes.javascript").prettier,
		},
		typescript = {
			require("formatter.filetypes.typescript").prettier,
		},
		typescriptreact = {
			require("formatter.filetypes.typescript").prettier,
		},
		json = {
			require("formatter.filetypes.json").prettier,
		},
		toml = {
			require("formatter.filetypes.toml").taplo,
		},
		python = {
			require("formatter.filetypes.python").ruff,
		},
		go = {
			require("formatter.filetypes.go").gofmt,
		},
		rust = {
			require("formatter.filetypes.rust").rustfmt,
		},
		lua = {
			require("formatter.filetypes.lua").stylua,
		},
	},
})
