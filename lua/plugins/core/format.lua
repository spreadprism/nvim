plugin("conform.nvim"):on_require("conform"):triggerUIEnter():after(function()
	local formatters = {
		["*"] = { "trim_whitespace" },
	}
	if nixCats("go") then
		formatters.go = { "goimports", "gofmt" }
	end
	if nixCats("lua") then
		formatters.lua = { "stylua" }
	end
	if nixCats("nix") then
		formatters.nix = { "alejandra" }
	end
	require("conform").setup({
		formatters_by_ft = formatters,
	})
	vim.api.nvim_create_autocmd("BufWritePre", {
		pattern = "*",
		callback = function(args)
			require("conform").format({ bufnr = args.buf })
		end,
	})
end)
