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

lsp("ty"):display(function()
	local name = "ty"
	local venv = require("venv-selector").venv()

	if venv then
		venv = vim.fs.basename(venv):gsub("^%.", "")
		name = name .. "(" .. venv .. ")"
	end

	return name
end)
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
		module.resolve_python = require("venv-selector").python()
	end)
