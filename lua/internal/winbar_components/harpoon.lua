local M = {}

M.component = {
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
	color = { fg = Colors.red, bg = "none" },
	cond = require("internal.winbar").winbar_cond(function()
		local ok, _ = pcall(require, "harpoon")
		return ok
	end),
	separator = "",
	padding = { left = 0, right = 1 },
}

return M
