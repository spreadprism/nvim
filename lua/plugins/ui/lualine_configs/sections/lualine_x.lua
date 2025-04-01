local dont_show_lsp = {
	"copilot",
}

return {
	{
		function()
			local all_clients = vim.lsp.get_clients({ bufnr = vim.fn.bufnr() }) or {}

			local displays = {}
			for _, client in pairs(all_clients) do
				local name = client.name
				if not vim.tbl_contains(dont_show_lsp, name) then
					table.insert(displays, name)
				end
			end

			return table.concat(displays, " | ")
		end,
	},
	{
		"diagnostics",
		sources = { "nvim_workspace_diagnostic" },
		symbols = { error = Symbols.error, warn = Symbols.warn, hint = Symbols.hint },
		diagnostics_color = {
			color_error = { fg = Colors.red },
			color_warn = { fg = Colors.yellow },
			color_info = { fg = Colors.cyan },
		},
		sections = { "error", "warn", "hint" },
		always_visible = true,
	},
}
