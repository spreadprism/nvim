local lint = require("lint")

lint.linters_by_ft = {
	javascript = { "eslint" },
	typescript = { "eslint" },
	typescriptreact = { "eslint" },
	css = { "stylelint" },
}

local events = { "TextChanged", "BufReadPost", "BufWritePost" }
for _, value in pairs(events) do
	vim.api.nvim_create_autocmd({ value }, {
		callback = function()
			require("lint").try_lint()
		end,
	})
end
