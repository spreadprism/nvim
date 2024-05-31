local current_lsp = function()
	local all_clients = vim.lsp.get_clients({ bufnr = vim.fn.bufnr() }) or {}

	local displays = {}
	for _, client in pairs(all_clients) do
		local name = client.name
		table.insert(displays, require("utils.lsp").get_display(name))
	end

	return table.concat(displays, " | ")
end
return {
	{
		"overseer",
		unique = true,
		symbols = {
			[require("overseer").STATUS.RUNNING] = "󰦖 ",
		},
	},

	{
		current_lsp,
		cond = function()
			return current_lsp() ~= nil
		end,
	},
	{
		"diagnostics",
		sources = { "nvim_workspace_diagnostic" },
		symbols = { error = " ", warn = " ", hint = "󰌵 " },
		diagnostics_color = {
			color_error = { fg = Colors.red },
			color_warn = { fg = Colors.yellow },
			color_info = { fg = Colors.cyan },
		},
		sections = { "error", "warn", "hint" },
		always_visible = true,
	},
}
