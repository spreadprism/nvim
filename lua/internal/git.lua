-- Small git helpers that wrap plugin internals we call from keymaps.

local M = {}

--- Window kinds accepted by neogit's `Buffer.create` (`:h neogit-config-kind`).
---@alias NeogitWindowKind
---| "tab"
---| "replace"
---| "split"
---| "split_above"
---| "split_above_all"
---| "split_below"
---| "split_below_all"
---| "vsplit"
---| "vsplit_left"
---| "floating"
---| "floating_console"
---| "popup"
---| "auto"

---@class InternalGitCommitOpts
---@field kind? NeogitWindowKind window to open the view in. Defaults to
---  neogit's own `commit_view.kind`.
---@field filter? string[] restrict the diffs to these paths (repo-relative).
---@field close? boolean close an already open commit view first. Defaults to
---  true: neogit keeps a single `CommitView.instance`, and opening a second
---  one leaks the previous buffer.

--- Open neogit's commit view for a commit hash.
---
--- `CommitView.new` shells out to `git show` synchronously, so an invalid or
--- unreachable hash would blow up inside the parser; the rev is verified first
--- and a bad one is reported instead.
---@param hash string commit-ish (hash, tag, `HEAD~2`, ...)
---@param opts? InternalGitCommitOpts
---@return CommitViewBuffer|nil view the opened view, or nil when it failed
function M.commit(hash, opts)
	opts = opts or {}

	if type(hash) ~= "string" or hash == "" then
		vim.notify("git.commit: expected a commit hash", vim.log.levels.ERROR)
		return nil
	end

	local ok, CommitView = pcall(require, "neogit.buffers.commit_view")
	if not ok then
		vim.notify("git.commit: neogit is not available", vim.log.levels.ERROR)
		return nil
	end

	-- `^{commit}` also rejects refs that resolve to a tree/blob, which the view
	-- cannot render
	local rev = vim.system({ "git", "rev-parse", "--verify", "--quiet", hash .. "^{commit}" }):wait()
	if rev.code ~= 0 then
		vim.notify(("git.commit: no such commit: %s"):format(hash), vim.log.levels.ERROR)
		return nil
	end

	if opts.close ~= false and CommitView.instance then
		pcall(function()
			CommitView.instance:close()
		end)
	end

	local view = CommitView.new(vim.trim(rev.stdout), opts.filter)
	view:open(opts.kind)

	return view
end

return M
