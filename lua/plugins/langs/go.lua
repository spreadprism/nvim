lsp("gopls")
	:for_cat("language.go")
	:ft("go", "gomod", "gosum", "gowork", "gotmpl")
	:root_markers("go.work", "go.mod", ".git")
	:settings({
		gopls = {
			directoryFilters = {
				"-/nix/**",
				string.format("-%s/**", os.getenv("GOPATH")),
			},
			["ui.inlayhint.hints"] = {
				assignVariableTypes = true,
				constantValues = true,
				rangeVariableTypes = true,
				functionTypeParameters = true,
			},
		},
	})
linter("go", "golangcilint")
formatter("go", "gofumpt")
plugin("nvim-dap-go"):for_cat("language.go"):on_require("dap-go"):ft("go"):config(function()
	require("dap-go").setup({})
	require("internal.dap").clear("go")
end)
plugin("neotest-golang"):config(false):on_plugin("neotest"):for_cat("language.go")
