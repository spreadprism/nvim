plugin("conform.nvim"):on_require("conform"):triggerUIEnter():after(function()
	require("conform").setup({
		formatters_by_ft = vim.tbl_extend("error", require("internal.formatter").formatter_by_ft, {
			["*"] = { "trim_whitespace" },
		}),
	})
	vim.api.nvim_create_autocmd("BufWritePre", {
		pattern = "*",
		callback = function(args)
			require("conform").format({ bufnr = args.buf })
		end,
	})
end)
