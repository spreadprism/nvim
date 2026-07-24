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

plugin("py-requirements")
	:event("DeferredUIEnter")
	:after(function()
		-- The plugin sets its diagnostics at col 0 with no end_col, so only the
		-- first character is highlighted. Rewrite them to span just the package
		-- spec (e.g. `pydantic>=2.13.4`) using the plugin's own parsed packs.
		local ns = vim.api.nvim_create_namespace("py-requirements.nvim")
		local patching = false
		vim.api.nvim_create_autocmd("DiagnosticChanged", {
			callback = function(args)
				if patching then
					return
				end
				local buf = args.buf
				local diags = vim.diagnostic.get(buf, { namespace = ns })
				if #diags == 0 then
					return
				end

				-- map each line (row) to its parsed pack for exact column ranges
				local ok, parser = pcall(require, "py-requirements.parser")
				if not ok then
					return
				end
				local by_row = {}
				for _, pack in ipairs(parser.buf(buf)) do
					by_row[pack.row] = pack
				end

				local changed = false
				for _, d in ipairs(diags) do
					local pack = by_row[d.lnum]
					local line = vim.api.nvim_buf_get_lines(buf, d.lnum, d.lnum + 1, false)[1] or ""
					if pack then
						-- start = package name column, end = last version spec end
						local name_start = line:find(vim.pesc(pack.name)) or 1
						local spec = pack.specs and pack.specs[#pack.specs]
						local end_col = spec and spec.cols and spec.cols[2] or #line
						d.col = name_start - 1
						d.end_lnum = d.lnum
						d.end_col = end_col
						changed = true
					end
				end
				if changed then
					patching = true
					vim.diagnostic.set(ns, buf, diags)
					patching = false
				end
			end,
		})
	end)
	:keymaps({
		k:map("n", "K", k:require("py-requirements").show_description(), "show description"):pattern("pyproject.toml"),
		k:map("n", "<localleader>u", k:require("py-requirements").upgrade(), "upgrade dependency")
			:pattern({ "requirements.txt", "pyproject.toml" }),
	})
