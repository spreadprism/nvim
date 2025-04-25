lsp("basedpyright"):for_cat("python"):settings({
	basedpyright = {
		analysis = {
			diagnosticSeverityOverrides = {
				reportAny = "none", -- Disable the specific rule
			},
		},
	},
})
lsp("ruff"):for_cat("python")
formatter("python", "ruff_format")
plugin("venv-selector"):for_cat("python"):ft("python"):on_plugin("nvim-dap-python"):on_require("venv-selector")
plugin("nvim-dap-python"):for_cat("python"):on_require("dap-python"):ft("python"):config(function()
	require("dap-python").setup(require("venv-selector").python())
	require("internal.dap").clear("python")
end)
