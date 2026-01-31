return {
	init = function(self)
		self.tabs = vim.api.nvim_list_tabpages()
		self.tabnr = vim.api.nvim_get_current_tabpage()

		local elements = {}

		for i, tab in ipairs(self.tabs) do
			local hl = tab == self.tabnr and {
				fg = self.mode_color(),
			} or {
				fg = colors.fg_gutter,
			}
			table.insert(elements, {
				hl = hl,
				provider = " " .. i .. " ",
			})
		end
		self.child = self:new(elements, 1)
	end,
	provider = function(self)
		return self.child:eval()
	end,
	condition = function()
		return #vim.api.nvim_list_tabpages() > 1
	end,
}
