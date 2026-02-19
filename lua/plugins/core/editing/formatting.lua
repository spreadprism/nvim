plugin("conform")
	:event("DeferredUIEnter")
	:opts({
		formatters_by_ft = {
			["*"] = { "trim_whitespace" },
		},
	})
	:after(function()
		vim.api.nvim_create_autocmd("BufWritePre", {
			pattern = "*",
			callback = function(args)
				require("conform").format({ bufnr = args.buf })
			end,
		})
	end)
