plugin("mfussenegger/nvim-lint"):event("VeryLazy"):config(function()
	local lint = require("lint")
	local linters = require("internal.linting").list_linters()

	local tmp = {}
	for _, linter in ipairs(linters) do
		tmp[linter.lang] = { linter.name }
	end

	lint.linters_by_ft = tmp

	local events = { "TextChanged", "BufReadPost", "BufWritePost" }
	for _, value in pairs(events) do
		vim.api.nvim_create_autocmd({ value }, {
			callback = function()
				require("lint").try_lint()
			end,
		})
	end
end)
