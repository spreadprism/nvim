return {
	static = {
		get_visual_selection = function()
			return table.concat(vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos(".")), "\n")
		end,
	},
	init = function(self)
		local selection = self.get_visual_selection()
		self.count_lines = 0
		self.count_chars = 0

		if vim.tbl_contains({ "v", "V", "" }, vim.fn.mode()) and selection ~= "" then
			local lines = vim.split(selection, "\n", { plain = true })
			self.count_lines = #lines
			for _, line in ipairs(lines) do
				self.count_chars = self.count_chars + #line
			end
		end
	end,
	update = { "CursorMoved", "ModeChanged" },
	-- {
	-- 	provider = function(_)
	-- 		return symbols.separators.angle.right
	-- 	end,
	-- 	hl = function(self)
	-- 		return { fg = self.mode_color(), bold = true }
	-- 	end,
	-- },
	{
		provider = function(self)
			return " " .. self.count_chars .. ":" .. self.count_lines .. " "
		end,
		hl = function(self)
			return { fg = colors.black, bg = self.mode_color(), bold = true }
		end,
	},
}
