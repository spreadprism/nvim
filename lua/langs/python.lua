-- -- missing feature: https://github.com/astral-sh/ty/issues/3561
lsp("ty"):display(function()
	local name = "ty"
	local venv = require("venv-selector").venv()

	if venv then
		venv = vim.fs.basename(venv):gsub("^%.", "")
		name = name .. "(" .. venv .. ")"
	end

	return name
end)

-- lsp("basedpyright"):display(function()
-- 	local name = "basedpyright"
-- 	local venv = require("venv-selector").venv()
--
-- 	if venv then
-- 		local label
-- 		label = vim.fs.basename(venv):gsub("^%.", "")
-- 		name = name .. "(" .. label .. ")"
-- 	end
--
-- 	return name
-- end):settings({
-- 	basedpyright = {
-- 		analysis = {
-- 			autoFormatStrings = true,
-- 		},
-- 	},
-- })

lsp("ruff"):display(false):init_options({
	settings = {
		showSyntaxErrors = false,
		lint = {
			-- basedpyright owns these checks; disable the overlapping ruff rules
			-- so they aren't reported twice.
			-- ignore = {
			-- 	"F401", -- unused import (basedpyright reportUnusedImport)
			-- 	"F841", -- unused variable (reportUnusedVariable)
			-- 	"F842", -- unused annotation (annotated but never used)
			-- 	"F811", -- redefinition (reportRedeclaration / reportDuplicateImport)
			-- 	"F821", -- undefined name (reportUndefinedVariable)
			-- 	"F822", -- undefined name in __all__ (reportUnsupportedDunderAll)
			-- 	"B018", -- useless expression (reportUnusedExpression)
			-- },
		},
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
			k:map("n", "p", function()
				local file = fs.find_up("pyproject.toml")
				if file then
					vim.cmd.edit(file)
				else
					vim.notify("pyproject.toml not found", vim.log.levels.WARN)
				end
			end, "go to pyproject.toml"),
			k:map("n", "r", function()
				vim.cmd.edit(fs.find_up("requirements.txt", { create = true }))
			end, "go to requirements.txt"),
		}):ft("python"),
	})
