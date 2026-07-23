-- missing feature: https://github.com/astral-sh/ty/issues/3561
-- lsp("ty"):display(function()
-- 	local name = "ty"
-- 	local venv = require("venv-selector").venv()
--
-- 	if venv then
-- 		venv = vim.fs.basename(venv):gsub("^%.", "")
-- 		name = name .. "(" .. venv .. ")"
-- 	end
--
-- 	return name
-- end)

--"/home/avalon/Projects/Personal/labyrinth/.venv"
lsp("basedpyright"):display(function()
	local name = "basedpyright"
	local venv = require("venv-selector").venv()

	if venv then
		local label
		label = vim.fs.basename(venv):gsub("^%.", "")
		name = name .. "(" .. label .. ")"
	end

	return name
end):settings({
	basedpyright = {
		analysis = {
			diagnosticMode = "workspace",
			autoFormatStrings = true,
			-- ruff owns lint rules that overlap with basedpyright; disable the
			-- overlapping diagnostics so they aren't reported twice.
			diagnosticSeverityOverrides = {
				reportUnusedImport = "none", -- ruff F401
				reportUnusedVariable = "none", -- ruff F841
				reportUnusedClass = "none", -- ruff (unused private symbol)
				reportUnusedFunction = "none", -- ruff (unused private symbol)
				reportUndefinedVariable = "none", -- ruff F821
				reportUnsupportedDunderAll = "none", -- ruff F822
				reportRedeclaration = "none", -- ruff F811
				reportDuplicateImport = "none", -- ruff F811
				reportUnusedExpression = "none", -- ruff B018 / F-family
			},
		},
	},
})

lsp("ruff"):display(false):init_options({
	settings = {
		showSyntaxErrors = false,
	},
})

formatter("python", "ruff_format")

plugin("dap-python")
	:dep_on({
		"nvim-dap",
		"venv-selector",
	})
	:ft("python")
	:opts(false)
	:after(function()
		local module = require("dap-python")
		module.setup("uv", { include_configs = false })
		module.resolve_python = require("venv-selector").python
	end)
plugin("venv-selector")
	:ft("python")
	:opts({
		search = {
			pipx = false,
		},
	})
	:keymaps({
		k:group("python", "<localleader>", {
			k:map("n", "e", k:cmd("VenvSelect"), "venv select"),
		}):ft("python"),
	})
