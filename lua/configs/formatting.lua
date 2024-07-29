vim.api.nvim_create_autocmd({ "BufWritePost" }, {
	callback = function()
		if not vim.g.format_ft[vim.bo.filetype] then
			return
		end
		if vim.g.format_ft["*"] then
			return
		end
		vim.cmd("silent FormatWriteLock")
	end,
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
			vim.lsp.buf.format, -- BUG: Formatting json that removes line causes error (PR is opened)
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
		css = {
			require("formatter.filetypes.css").prettier,
		},
		lua = {
			require("formatter.filetypes.lua").stylua,
		},
	},
})
