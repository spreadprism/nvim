plugin("nvim-lint"):on_require("lint"):after(function()
	local linters = {}
	if nixCats("go") then
		linters.go = { "golangcilint" }
	end
	require("lint").linters_by_ft = linters
	vim.api.nvim_create_autocmd({ "BufWritePost" }, {
		callback = function()
			require("lint").try_lint()
		end,
	})
end)
