if nixCats("go") then
	lsp("gopls"):settings({
		directoryFilters = {
			"-/nix/**",
		},
	})
	-- BUG: nvim-lint currently doesn't support v2 see: https://github.com/mfussenegger/nvim-lint/pull/761
	-- linter("go", "golangcilint")
	plugin("nvim-dap-go")
		:on_require("dap-go")
		:ft("go")
		:config(function()
			require("dap-go").setup({})
			require("internal.dap").clear("go")
		end)
		:on_plugin("nvim-dap")
	plugin("neotest-golang"):config(false):ft("go"):on_plugin("neotest")
	formatter("go", { "goimports", "gofmt" })
end
