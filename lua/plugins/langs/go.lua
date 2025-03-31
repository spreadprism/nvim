if nixCats("go") then
	lsp("gopls"):settings({
		directoryFilters = {
			"-/nix/**",
		},
	}):ft("go")
	formatter("go", { "goimports", "gofmt" })
	-- linter("go", "golangcilint") # BUG: its broken for some reason
	plugin("nvim-dap-go"):on_require("dap-go"):ft("go"):after(function()
		require("dap-go").setup({})
		require("internal.dap").clear("go")
	end)
	plugin("neotest-golang"):after(nil):ft("go")
end
