-- BUG: nvim-lint currently doesn't support v2 see: https://github.com/mfussenegger/nvim-lint/pull/761
-- linter("go", "golangcilint")
plugin("nvim-dap-go")
	:for_cat("go")
	:on_require("dap-go")
	:ft("go")
	:config(function()
		require("dap-go").setup({})
		require("internal.dap").clear("go")
	end)
	:on_plugin("nvim-dap")
plugin("neotest-golang"):config(false):on_plugin("neotest"):for_cat("go")
formatter("go", { "goimports", "gofmt" })
lsp("gopls")
	:for_cat("go")
	:ft("go", "gomod", "gosum", "gowork", "gotmpl")
	:root_markers("go.work", "go.mod", ".git")
	:settings({
		directoryFilters = {
			"-/nix/**",
			string.format("-%s/**", os.getenv("GOBIN")),
		},
	})
