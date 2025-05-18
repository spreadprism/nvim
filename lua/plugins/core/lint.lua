vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
	callback = function()
		require("lint").try_lint()
	end,
})
plugin("nvim-lint")
	:on_require("lint")
	:config(function()
		require("lint").linters_by_ft = require("internal.linter").linter_by_ft
	end)
	:event_defer()
