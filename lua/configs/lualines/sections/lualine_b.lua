local ll_utils = require("utils.lualine_utils")
return {
	{
		"branch",
		on_click = ll_utils.cmd_on_click("Neogit"),
	},
	{
		"filetype",
		icon_only = true,
		separator = "",
		padding = { left = 1, right = 1 },
		cond = ll_utils.display_file,
	},
	{
		"filename",
		path = 0,
		separator = "",
		padding = { left = 0, right = 1 },
		symbols = { modified = Symbols.modified, readonly = Symbols.readonly, unnamed = "" },
		cond = ll_utils.display_file,
	},
	{
		function()
			local marks = require("harpoon"):list().items
			local current_buffer = vim.fn.expand("%s"):gsub(vim.fn.getcwd() .. "/", "")

			for _, mark in ipairs(marks) do
				if current_buffer == mark.value then
					return ""
				end
			end
			return ""
		end,
		color = { fg = Colors.red },
		separator = "",
		padding = { left = 0, right = 1 },
	},
}
