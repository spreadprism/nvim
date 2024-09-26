local TS_ENSURE_INSTALLED_KEY = "TS_ensure_installed"

vim.api.nvim_create_user_command("TSAdd", function(opts)
	vim.cmd("TSInstall " .. opts.args)
	local valid_parsers = require("nvim-treesitter.parsers").available_parsers()
	local ensure_installed = state.get(TS_ENSURE_INSTALLED_KEY) or {}
	local args = vim.fn.split(opts.args, " ")
	for _, arg in ipairs(args) do
		if vim.tbl_contains(valid_parsers, arg) and not vim.tbl_contains(ensure_installed, arg) then
			table.insert(ensure_installed, arg)
		end
	end
	state.set(TS_ENSURE_INSTALLED_KEY, ensure_installed)
end, { nargs = "+", complete = "custom,nvim_treesitter#installable_parsers" })

local M = {}

M.ensure_installed = function()
	return state.get(TS_ENSURE_INSTALLED_KEY) or {} ---@type string[]
end

return M
