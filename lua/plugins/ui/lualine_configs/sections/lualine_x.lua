return {
	{
		"overseer",
		unique = true,
		symbols = {
			["RUNNING"] = "󰦖 ",
		},
	},
	{
		function()
			return table.concat(require("internal.lsp").get_clients(vim.fn.bufnr()), ", ")
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
