--- Resolve the actual git dir for a work tree root.
--- Handles worktrees/submodules where `.git` is a file containing
--- `gitdir: /path/to/repo/worktrees/<name>` (path may be relative).
---@param root string work tree root
---@return string|nil git_dir
local function resolve_git_dir(root)
	local git_path = vim.fs.joinpath(root, ".git")
	local stat = vim.uv.fs_stat(git_path)
	if not stat then
		return nil
	end

	if stat.type == "directory" then
		return git_path
	end

	local line = vim.fn.readfile(git_path)[1] or ""
	local git_dir = line:match("^gitdir:%s*(.-)%s*$")
	if not git_dir or git_dir == "" then
		return nil
	end

	if not vim.startswith(git_dir, "/") then
		git_dir = vim.fs.normalize(vim.fs.joinpath(root, git_dir))
	end

	return git_dir
end

--- Read the current branch (or short sha when detached) from a git dir.
---@param git_dir string
---@return string|nil
local function head_of(git_dir)
	local ref = vim.fn.readfile(vim.fs.joinpath(git_dir, "HEAD"))[1] or ""

	local branch = ref:match("ref: refs/heads/(.+)")
	if branch then
		return branch
	end

	local sha = ref:match("^(%x%x%x%x%x%x%x)%x*$")
	if sha then
		return sha
	end

	return nil
end

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
				local git_dir = resolve_git_dir(root)
				local b = git_dir and head_of(git_dir)
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
