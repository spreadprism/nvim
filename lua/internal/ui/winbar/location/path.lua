return {
	static = {
		get_icon = require("nvim-web-devicons").get_icon,
		get_icon_filetype = require("nvim-web-devicons").get_icon_by_filetype,
	},
	condition = function(self)
		return self.root ~= self.path
	end,
	init = function(self)
		local childs = {}

		local rel_path = self.path:gsub("^" .. self.root .. "", "")

		local elements = vim.split(rel_path, "/")
		for i, e in ipairs(elements) do
			if i == #elements and self.ft ~= "oil" then
				local icon, hl = self.get_icon(self.path)
				if icon == nil then
					icon, hl = self.get_icon_filetype(self.ft)
				end
				if icon then
					table.insert(childs, {
						provider = icon .. " ",
						hl = hl,
					})
				end
			end
			table.insert(childs, {
				provider = e,
				hl = i == #elements and { fg = colors.fg } or nil,
			})

			if i < #elements then
				table.insert(childs, {
					provider = self.symbols.separator,
				})
			end
		end

		self.child = self:new(childs, 1)
	end,
	provider = function(self)
		return self.child:eval()
	end,
}
