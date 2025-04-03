plugin("conform.nvim")
	:event_ui()
	:opts(function()
		return {
			formatters_by_ft = vim.tbl_deep_extend("error", require("internal.formatter").formatter_by_ft, {
				["*"] = { "trim_whitespace" },
			}),
		}
	end)
	:setup(function()
		vim.api.nvim_create_autocmd("BufWritePre", {
			pattern = "*",
			callback = function(args)
				require("conform").format({ bufnr = args.buf })
			end,
		})
	end)
