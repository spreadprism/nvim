if nixCats("go") then
	lsp("gopls"):settings({
		directoryFilters = {
			"-/nix/**",
		},
	}):ft("go")
	plugin("nvim-dap-go")
		:on_require("dap-go")
		:ft("go")
		:after(function()
			require("dap-go").setup({})
			require("internal.dap").clear("go")
		end)
		:on_plugin("nvim-dap")
	plugin("neotest-golang"):after(nil):ft("go"):on_plugin("neotest")
	formatter("go", { "goimports", "gofmt" })
	linter("go", "golangcilint")
end
