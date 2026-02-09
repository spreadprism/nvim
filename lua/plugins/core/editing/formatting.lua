plugin("conform")
	:event("DeferredUIEnter")
	:opts({
		formatters_by_ft = {
			["*"] = { "trim_whitespace" },
		},
	})
	:after(function()
		local conform = require("conform")

		conform.formatters_by_ft = vim.tbl_deep_extend(
			"force",
			conform.formatters_by_ft,
			require("internal.loader.formatter").formatters_by_ft
		)

		vim.api.nvim_create_autocmd("BufWritePre", {
			pattern = "*",
			callback = function(args)
				conform.format({ bufnr = args.buf })
			end,
		})
	end)
