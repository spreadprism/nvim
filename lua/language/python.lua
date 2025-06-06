if not nixCats("language.python") then
	return
end
lsp("basedpyright"):settings({
	basedpyright = {
		analysis = {
			inlayHints = {
				callArgumentNames = false,
				genericTypes = true,
			},
			diagnosticSeverityOverrides = {
				reportAny = "none", -- Disable the specific rule
				reportExplicitAny = "none", -- Disable the specific rule
			},
		},
	},
})
lsp("ruff"):init_options({
	settings = {
		showSyntaxErrors = false,
		lint = {
			ignore = { "F401", "F841" },
		},
	},
})
formatter("python", "ruff_format")
plugin("venv-selector")
	:ft("python")
	:on_plugin("nvim-dap-python")
	:on_require("venv-selector")
	:opts({
		-- TODO: add support for conda/mamba env
		search = {
			pipx = false,
			poetry = false,
		},
	})
	:setup(function()
		kgroup("<leader>l", "lsp", {}, {
			kmap("n", "e", kcmd("VenvSelect"), "select venv"),
			kmap("n", "d", klazy("venv-selector").deactivate(), "deactivate current env"),
		})
	end)
plugin("nvim-dap-python"):dep_on("nvim-dap"):on_require("dap-python"):ft("python"):config(function()
	require("dap-python").setup("uv", { include_configs = false })
	require("dap-python").resolve_python = function()
		local path = require("venv-selector").python()
		if path then
			return path
		end

		---@diagnostic disable-next-line: redefined-local
		local path, err = exec("command -v python")
		if not err == nil then
			return path
		end
		path, err = exec("command -v python3")
		if not err == nil then
			return path
		end

		return nil
	end
end)
