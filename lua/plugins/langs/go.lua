lsp("gopls")
	:for_cat("language.go")
	:ft("go", "gomod", "gosum", "gowork", "gotmpl")
	:root_markers("go.work", "go.mod", ".git")
	:settings({
		directoryFilters = {
			"-/nix/**",
			string.format("-%s/**", os.getenv("GOPATH")),
		},
	})
linter("go", "golangcilint")
formatter("go", "gofumpt")
plugin("nvim-dap-go")
	:for_cat("language.go")
	:on_require("dap-go")
	:ft("go")
	:config(function()
		require("dap-go").setup({})
		require("internal.dap").clear("go")
	end)
	:dep_on("nvim-dap")
plugin("neotest-golang"):config(false):on_plugin("neotest"):for_cat("language.go")
