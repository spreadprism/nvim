--- Resolve the actual git dir for a work tree root.
--- Handles worktrees/submodules where `.git` is a file containing
--- `gitdir: /path/to/repo/worktrees/<name>` (path may be relative).
---@param root string work tree root
---@return string? git_dir
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
---@return string?
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

--- Find the git dir governing a path (file or directory).
---@param path string
---@return string? git_dir
local function git_dir_of(path)
	if not path or path == "" then
		return nil
	end

	local stat = vim.uv.fs_stat(path)
	local dir = (stat and stat.type == "directory") and path or vim.fs.dirname(path)

	local dot_git = vim.fs.find(".git", { path = dir, upward = true, limit = 1 })[1]
	if not dot_git then
		return nil
	end

	return resolve_git_dir(vim.fs.dirname(dot_git))
end

--- branch cache, keyed by directory (git dir resolution + HEAD read are the
--- expensive parts, and this provider runs several times per redraw)
---@type table<string, { git_dir: string|false, branch: string|false }>
local cache = {}

--- one fs_event per git dir, so branch switches made by worktrunk, the shell,
--- or any other tool refresh the statusline without polling
---@type table<string, uv.uv_fs_event_t>
local watchers = {}

local function invalidate(git_dir)
	for dir, entry in pairs(cache) do
		if entry.git_dir == git_dir then
			cache[dir] = nil
		end
	end
	vim.cmd.redrawstatus()
end

---@param git_dir string
local function watch_head(git_dir)
	if watchers[git_dir] then
		return
	end

	local watcher = vim.uv.new_fs_event()
	if not watcher then
		return
	end

	watchers[git_dir] = watcher
	watcher:start(git_dir, {}, function(err, filename)
		if err then
			return
		end
		-- git writes HEAD.lock then renames, so accept both
		if filename and filename ~= "HEAD" and filename ~= "HEAD.lock" then
			return
		end
		vim.schedule(function()
			invalidate(git_dir)
		end)
	end)
end

---@param dir string directory to resolve the branch for
---@return string?
local function get_path_branch(dir)
	if not dir or dir == "" then
		return nil
	end

	local entry = cache[dir]
	if not entry then
		local git_dir = git_dir_of(dir)
		entry = {
			git_dir = git_dir or false,
			branch = (git_dir and head_of(git_dir)) or false,
		}
		cache[dir] = entry
		if git_dir then
			watch_head(git_dir)
		end
	end

	return entry.branch or nil
end

local group = vim.api.nvim_create_augroup("status_git", { clear = true })

-- any cwd change (`cd`, `tcd` from worktrunk, `lcd`) may point at another
-- work tree, and directories can be swapped underneath us, so drop the cache
vim.api.nvim_create_autocmd({ "DirChanged", "BufFilePost", "BufWritePost" }, {
	group = group,
	callback = function()
		cache = {}
	end,
})

---@param bufnr integer
---@return string?
local function get_buf_branch(bufnr)
	-- window-local cwd, so `tcd`/`lcd` (worktree switches) are respected
	local cwd = vim.fn.getcwd()

	if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
		return get_path_branch(cwd)
	end

	local dir
	if vim.bo[bufnr].filetype == "oil" then
		local ok, oil = pcall(require, "oil")
		dir = ok and oil.get_current_dir(bufnr) or nil
	elseif vim.bo[bufnr].buftype == "" then
		local name = vim.api.nvim_buf_get_name(bufnr)
		dir = name ~= "" and vim.fs.dirname(name) or nil
	end

	-- special buffers (NeogitStatus, terminals, pickers, ...) and unnamed
	-- buffers describe the workspace, not a file
	if not dir then
		return get_path_branch(cwd)
	end

	return get_path_branch(vim.fs.normalize(dir))
end

return {
	fallthrough = false,
	{
		provider = " ",
		condition = function(self)
			return not get_buf_branch(self.bufnr)
		end,
		hl = { link = "Comment" },
	},
	{
		init = function(self)
			self.branch = get_buf_branch(self.bufnr)
		end,
		condition = function(self)
			return get_buf_branch(self.bufnr) ~= nil
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
