local symbol = ""
return {
	{
		init = function(self)
			self.session = require("dap").session()
		end,
		provider = function(self)
			if self.session then
				local name = self.session.config and self.session.config.name or ""
				return symbol .. " (" .. name .. ")"
			else
				return symbol
			end
		end,
		hl = function(self)
			if self.session then
				if self.session.initialized then
					return { fg = colors.green }
				else
					return { fg = colors.blue }
				end
			else
				return { fg = colors.comment }
			end
		end,
	},
}
