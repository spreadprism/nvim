return {
	{ "branch", on_click = internal.cmd_on_click("Neogit"), separator = "" },
	{
		"diff",
		colored = true,
		padding = { left = 0, right = 1 },
		source = function()
			if not internal.plugin_loaded("gitsigns.nvim") then
				return {}
			end
			local gitsigns = vim.b.gitsigns_status_dict
			if gitsigns then
				return {
					added = gitsigns.added,
					modified = gitsigns.changed,
					removed = gitsigns.removed,
				}
			end
		end,
	},
}
