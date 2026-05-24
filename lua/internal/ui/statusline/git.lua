-- PERF: this is called 3 times every update
local function get_branch(buf)
	local ft = vim.bo.filetype

	local branch = vim.b.gitsigns_head or vim.g.gitsigns_head

	if ft == "NeogitStatus" then
		branch = vim.g.gitsigns_head
	elseif ft == "oil" then
		local path = require("oil").get_current_dir(buf)
		if path then
			local root, _ = require("oil-git.git").get_root(path)
			if root then
				-- read .git/HEAD
				local head_path = vim.fs.joinpath(root, ".git", "HEAD")
				local ref = vim.fn.readfile(head_path)[1] or ""
				local b = ref:match("ref: refs/heads/(.+)")
				if b then
					branch = b
				end
			end
		end
	end
	return branch
end

return {
	fallthrough = false,
	{
		provider = " ",
		condition = function(self)
			return not (get_branch(self.buf))
		end,
		hl = { link = "Comment" },
	},
	{
		init = function(self)
			self.branch = get_branch(self.buf)
		end,
		condition = function(self)
			return get_branch(self.buf)
		end,
		hl = function(self)
			return { fg = self.mode_color() }
		end,
		{
			provider = " ",
		},
		{ -- git branch name
			provider = function(self)
				return self.branch
			end,
			-- update = { "BufEnter", "TextChanged", "TextChangedI" },
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
			{
				provider = " ┃ ",
				hl = function(self)
					return { fg = self.mode_color() }
				end,
			},
		},
	},
}
