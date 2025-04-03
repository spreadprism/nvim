plugin("conform.nvim")
	:event_user()
	:opts({
		formatters_by_ft = vim.tbl_extend("error", require("internal.formatter").formatter_by_ft, {
			["*"] = { "trim_whitespace" },
		}),
	})
	:setup(function()
		vim.api.nvim_create_autocmd("BufWritePre", {
			pattern = "*",
			callback = function(args)
				require("conform").format({ bufnr = args.buf })
			end,
		})
	end)
