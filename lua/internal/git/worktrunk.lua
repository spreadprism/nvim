--- Custom snacks picker for worktrunk (`wt`) worktrees.
---
--- `wt.nvim` ships a telescope picker only, and falls back to `vim.ui.select`
--- otherwise. This module reuses its lua API (`worktrunk.worktree`) and renders
--- the worktrees with snacks instead, adding multi-select removal.
---@class internal.git.worktrunk
local M = {}

---@class internal.git.worktrunk.Item: snacks.picker.finder.Item
---@field branch string
---@field path? string
---@field current boolean
---@field main boolean
---@field worktrunk table raw `wt list` item

---@param item table raw item from `wt list --format=json`
---@return internal.git.worktrunk.Item
local function to_item(item)
	local util = require("worktrunk.util")
	local branch = item.branch or "?"
	local path = item.worktree and item.worktree.path or item.path

	return {
		text = table.concat({ branch, util.commit_message(item) }, " "),
		branch = branch,
		path = path,
		file = path,
		dir = path ~= nil,
		current = util.is_current(item),
		main = util.is_main(item),
		worktrunk = item,
	}
end

--- Async finder: `wt list` is a `vim.system` job, so suspend the picker task
--- until its callback fires.
---@type snacks.picker.finder
local function finder(_, ctx)
	return function(cb)
		local worktree = require("worktrunk.worktree")

		local result, done = nil, false
		worktree.list(function(err, items)
			result = { err = err, items = items or {} }
			done = true
			ctx.async:resume()
		end)

		if not done then
			ctx.async:suspend()
		end

		if result.err then
			require("worktrunk.ui").error(result.err.message)
			return
		end

		for i, item in ipairs(result.items) do
			local entry = to_item(item)
			cb(entry)
			if entry.current then
				ctx.picker.list:set_target(i)
			end
		end
	end
end

---@param item internal.git.worktrunk.Item
---@return snacks.picker.Highlight[]
local function format(item)
	local util = require("worktrunk.util")
	local a = Snacks.picker.util.align
	local raw = item.worktrunk

	local msg = util.commit_message(raw)
	if #msg > 60 then
		msg = msg:sub(1, 57) .. "..."
	end

	---@type snacks.picker.Highlight[]
	local ret = {}
	ret[#ret + 1] = { a(util.gutter(raw), 2), item.current and "SnacksPickerGitBranchCurrent" or "SnacksPickerComment" }
	ret[#ret + 1] = { a(item.branch, 30, { truncate = true }), "SnacksPickerGitBranch" }
	ret[#ret + 1] = { " " }
	ret[#ret + 1] = { a(util.sha(raw), 8), "SnacksPickerGitCommit" }
	ret[#ret + 1] = { a(util.symbols(raw), 6), "SnacksPickerGitStatus" }
	ret[#ret + 1] = { a(util.ahead_behind_str(raw), 8), "SnacksPickerComment" }
	ret[#ret + 1] = { msg, "SnacksPickerGitMsg" }
	return ret
end

--- Remove `branches` one after the other (`wt remove` is async), then refresh.
---@param branches string[]
---@param picker snacks.Picker
local function remove_all(branches, picker)
	local worktree = require("worktrunk.worktree")
	local ui = require("worktrunk.ui")

	local index = 0
	local function step()
		index = index + 1
		local branch = branches[index]

		if not branch then
			if not picker.closed then
				picker:refresh()
			end
			return
		end

		worktree.remove(branch, {}, function(err)
			if err then
				ui.error(("worktrunk: %s: %s"):format(branch, err.message))
			else
				ui.notify("Removed worktree " .. branch)
			end
			step()
		end)
	end

	step()
end

---@type table<string, snacks.picker.Action.spec>
local actions = {
	--- Switch to the worktree under the cursor.
	worktrunk_switch = function(picker, item)
		picker:close()
		if item then
			require("worktrunk").switch(item.branch)
		end
	end,

	--- Remove every selected worktree (or the one under the cursor), with a
	--- single confirmation for the whole batch.
	worktrunk_remove = function(picker)
		local items = picker:selected({ fallback = true })
		if #items == 0 then
			return
		end

		local branches = vim.tbl_map(function(item)
			return item.branch
		end, items)

		local prompt = #branches == 1 and ("Remove worktree %q?"):format(branches[1])
			or ("Remove %d worktrees? (%s)"):format(#branches, table.concat(branches, ", "))

		Snacks.picker.util.confirm(prompt, function()
			remove_all(branches, picker)
		end)
	end,

	--- Create a new worktree and close the picker.
	worktrunk_create = function(picker)
		picker:close()
		require("worktrunk").create()
	end,
}

--- Open the worktrunk picker.
---@param opts? snacks.picker.Config
function M.pick(opts)
	local ok = pcall(require, "snacks")
	if not ok then
		return require("worktrunk").list()
	end

	return Snacks.picker.pick(vim.tbl_deep_extend("force", {
		source = "worktrunk",
		title = "Worktrees",
		finder = finder,
		format = format,
		preview = "none",
		live = false,
		sort = { fields = { "score:desc", "idx" } },
		layout = { preset = "select" },
		confirm = "worktrunk_switch",
		actions = actions,
		win = {
			input = {
				keys = {
					["<C-d>"] = { "worktrunk_remove", mode = { "n", "i" } },
					["<C-n>"] = { "worktrunk_create", mode = { "n", "i" } },
				},
			},
			list = {
				keys = {
					["<C-d>"] = "worktrunk_remove",
					["<C-n>"] = "worktrunk_create",
				},
			},
		},
	}, opts or {}))
end

return M
