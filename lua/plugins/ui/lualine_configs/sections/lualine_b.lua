return {
	{ "branch", on_click = internal.cmd_on_click("Neogit") },
	{
		"filetype",
		icon_only = true,
		separator = "",
		padding = { left = 1, right = 1 },
		cond = internal.cond_buffer_blacklist,
	},
	{
		"filename",
		path = 0,
		separator = "",
		padding = { left = 0, right = 1 },
		symbols = { modified = Symbols.modified, readonly = Symbols.readonly, unnamed = "" },
		cond = internal.cond_buffer_blacklist,
	},
	{
		function()
			local ok, harpoon = pcall(require, "harpoon")

			if not ok then
				return ""
			end

			local marks = harpoon:list().items
			local current_buffer = vim.fn.expand("%s"):gsub(vim.fn.getcwd() .. "/", "")

			for _, mark in ipairs(marks) do
				if current_buffer == mark.value then
					return ""
				end
			end
			return ""
		end,
		color = { fg = Colors.red },
		cond = function()
			local ok, _ = pcall(require, "harpoon")
			return ok
		end,
		separator = "",
		padding = { left = 0, right = 1 },
	},
}
