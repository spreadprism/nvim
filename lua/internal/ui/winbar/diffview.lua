--- A winbar component that labels the side of a diffview diff window:
--- (OURS)/(THEIRS)/(BASE) while resolving conflicts, and the compared revs
--- (branch name, tag, short hash, LOCAL) otherwise.

local M = {}

---@return Window? window, table? view
local function current_window()
	local ok, lib = pcall(require, "diffview.lib")
	if not ok then
		return
	end

	local view = lib.get_current_view()
	local layout = view and view.cur_layout
	if not layout then
		return
	end

	local winid = vim.api.nvim_get_current_win()
	for _, window in ipairs(layout.windows or {}) do
		if window.id == winid then
			return window, view
		end
	end
end

--- conflict stages: 1 = common ancestor, 2 = current, 3 = incoming
local STAGE_LABEL = { [1] = "BASE", [2] = "OURS", [3] = "THEIRS" }

--- `ref_names` looks like "HEAD -> main, origin/main"; keep the first real name
---@param ref_names string?
---@return string?
local function first_ref(ref_names)
	if not ref_names or ref_names == "" then
		return nil
	end
	local name = vim.split(ref_names, ",")[1]
	name = vim.trim((name:gsub(".*%-> ", "")))
	return name ~= "" and name or nil
end

--- the revs a `DiffviewOpen` was started with, e.g. "main..feature" -> both sides
---@param view table
---@param symbol string
---@return string?
local function rev_arg_side(view, symbol)
	local rev_arg = view.rev_arg
	if type(rev_arg) ~= "string" or rev_arg == "" then
		return nil
	end

	local left, right = rev_arg:match("^(.-)%.%.%.?(.*)$")
	if not left then
		-- single rev: it names the left side, right side is its parent-of
		return symbol == "a" and rev_arg or nil
	end

	local side = symbol == "a" and left or right
	return side ~= "" and side or nil
end

---@param window Window
---@param view table
---@return string?
local function label_for(window, view)
	local file = window.file
	local rev = file and file.rev
	if not rev then
		return nil
	end

	local RevType = require("diffview.vcs.rev").RevType

	-- merge conflict: the stage number is authoritative
	if rev.type == RevType.STAGE and file.kind == "conflicting" then
		local label = STAGE_LABEL[rev.stage]
		if label then
			local ctx = view.merge_ctx
			local side = ctx and ({ BASE = ctx.base, OURS = ctx.ours, THEIRS = ctx.theirs })[label]
			local ref = side and first_ref(side.ref_names)
			return ref and ("%s (%s)"):format(label, ref) or label
		end
		return "INDEX"
	end

	if rev.type == RevType.STAGE then
		return "INDEX"
	end

	-- the working tree is what you normally look at: leave it unlabelled
	if rev.type == RevType.LOCAL then
		return nil
	end

	if rev.type == RevType.COMMIT then
		-- prefer the name the user typed (branch, tag, HEAD~2, ...)
		local named = rev_arg_side(view, file.symbol)
		if named then
			return named
		end

		-- `track_head` marks the rev diffview resolved from HEAD itself
		if rev.track_head then
			return "HEAD"
		end

		return rev:object_name(7)
	end
end

--- true when the current window is one of a diffview's diff windows
---@return boolean
function M.in_diff_window()
	return current_window() ~= nil
end

--- the real on-disk path of the file shown in the current diff window.
--- diff buffers are named `diffview://<toplevel>/.git/<hash>/<path>`, which is
--- useless as a breadcrumb.
---@return string?
function M.file_path()
	local window = current_window()
	local file = window and window.file
	return file and file.absolute_path or nil
end

--- true in the diff windows of a `DiffviewFileHistory` view
---@return boolean
function M.in_file_history()
	local _, view = current_window()
	return view ~= nil and view.class and view.class:name() == "FileHistoryView"
end

M.component = {
	condition = M.in_diff_window,
	init = function(self)
		local window, view = current_window()
		self.label = window and view and label_for(window, view) or nil
	end,
	provider = function(self)
		return self.label and (" (%s)"):format(self.label) or ""
	end,
	hl = { fg = colors.purple, italic = true },
}

return M
