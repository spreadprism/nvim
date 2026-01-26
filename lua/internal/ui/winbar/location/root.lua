return {
	init = function(self)
		if self.root == "/" then
			self.root_name = self.root
		elseif self.root == vim.env.HOME then
			self.root_name = "~"
		else
			self.root_name = vim.fn.fnamemodify(self.root, ":t")
		end
	end,
	provider = function(self)
		return self.root_name
	end,
	hl = function(self)
		return self.root == self.path and { fg = colors.fg } or { fg = colors.comment }
	end,
}
