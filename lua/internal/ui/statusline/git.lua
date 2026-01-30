return {
	init = function(self)
		self.branch = vim.b.gitsigns_head or require("neogit.lib.git.branch").current()
	end,
	hl = function(self)
		return { fg = self.mode_color() }
	end,
	{ -- git branch name
		provider = function(self)
			return "  " .. self.branch
		end,
		hl = { bold = true },
	},
	{
		init = function(self)
			self.status = vim.b.gitsigns_status_dict or {}

			self.added = self.status.added or 0
			self.removed = self.status.removed or 0
			self.changed = self.status.changed or 0

			self.has_added = self.added and self.added > 0
			self.has_removed = self.removed and self.removed > 0
			self.has_changed = self.changed and self.changed > 0
		end,
		{
			condition = function(self)
				return self.has_added or self.has_removed or self.has_changed
			end,
			provider = "(",
		},
		{
			condition = function(self)
				return self.has_added
			end,
			provider = function(self)
				return "+" .. self.added
			end,
			hl = { fg = colors.green },
		},
		{
			condition = function(self)
				return self.has_removed
			end,
			provider = function(self)
				return "-" .. self.removed
			end,
			hl = { fg = colors.red },
		},
		{
			condition = function(self)
				return self.has_changed
			end,
			provider = function(self)
				return "~" .. self.changed
			end,
			hl = { fg = colors.blue },
		},
		{
			condition = function(self)
				return self.has_added or self.has_removed or self.has_changed
			end,
			provider = ")",
		},
	},
}
