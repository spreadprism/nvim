--- Custom snacks picker for worktrunk (`wt`) worktrees.
---
--- `wt.nvim` ships a telescope picker only, and falls back to `vim.ui.select`
--- otherwise. This module reuses its lua API (`worktrunk.cmd`) and renders the
--- worktrees with snacks instead, adding multi-select removal and the `wt
--- switch` sigil filters.
---@class internal.git.worktrunk
local M = {}

---@class internal.git.worktrunk.Item: snacks.picker.finder.Item
---@field branch string
---@field path? string
---@field current boolean
---@field main boolean
---@field created boolean worktree already checked out on disk
---@field previous boolean previously visited worktree (`-`)
---@field remote? string remote name for remote-only branches
---@field pr? integer PR/MR number attached to the branch
---@field worktrunk table raw `wt list` item

---@class internal.git.worktrunk.State
---@field cache table<string, table[]> raw `wt list` items per mode
---@field kind? internal.git.worktrunk.Kind last parsed sigil, to detect changes

---@class internal.git.worktrunk.Config: snacks.picker.Config
---@field branches? boolean include local branches without a worktree (default true)
---@field remotes? boolean include remote-only branches (default true)
---@field wt_state? internal.git.worktrunk.State

---@alias internal.git.worktrunk.Kind "current"|"main"|"previous"|"pr"

-- Written as UTF-8 byte escapes so tooling can't strip the private-use
-- codepoints: U+F0765 `nf-md-circle` (filled) and U+F0766 `nf-md-circle_outline`.
local icons = {
	created = "\243\176\157\165",
	uncreated = "\243\176\157\166",
}

local hl = {
	-- same orange as the `@` gutter
	created = "SnacksPickerGitBranchCurrent",
	uncreated = "WorktrunkUncreated",
	added = "WorktrunkAdded",
	deleted = "WorktrunkDeleted",
}

--- First foreground colour found among `names`, ignoring groups that only set a
--- background (`DiffAdd` & friends).
---@param names string[]
---@return integer?
local function fg_of(names)
	for _, name in ipairs(names) do
		local ok, got = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
		if ok and got and got.fg then
			return got.fg
		end
	end
end

--- Blue circle for a branch without a worktree, and fg-only diff colours: the
--- diffstat must never paint a background, so the colours are copied out of the
--- usual git groups and re-declared with `bg = "NONE"`.
local function set_highlights()
	vim.api.nvim_set_hl(0, hl.uncreated, { fg = "#7aa2f7", default = true })
	vim.api.nvim_set_hl(0, hl.added, {
		fg = fg_of({ "Added", "diffAdded", "GitSignsAdd", "DiffAdd" }) or "#9ece6a",
		bg = "NONE",
	})
	vim.api.nvim_set_hl(0, hl.deleted, {
		fg = fg_of({ "Removed", "diffRemoved", "GitSignsDelete", "DiffDelete" }) or "#f7768e",
		bg = "NONE",
	})
end

--- `wt list --format=json` wraps its items in a schema-2 envelope; older
--- versions return a bare array (or a single object).
---@param data any
---@return table[]
local function extract_items(data)
	if type(data) ~= "table" then
		return {}
	end
	if data.schema == 2 then
		return data.items or {}
	end
	if data[1] ~= nil or #data == 0 then
		return data
	end
	return { data }
end

--- Run `wt list` synchronously. `wt` is fast and the result is cached for the
--- lifetime of the picker, so this avoids the async finder dance (snacks aborts
--- the finder task on every re-find, dropping late `cb()` calls).
---@param args string[]
---@return table[]? items, string? err
local function list(args)
	local binary = require("worktrunk.config").get().wt_binary or "wt"
	local cmd = { binary, "--config-set", "list.json-schema=2", "list" }
	vim.list_extend(cmd, args)
	cmd[#cmd + 1] = "--format=json"

	local obj = vim.system(cmd, { text = true }):wait()
	if obj.code ~= 0 then
		return nil, vim.trim(obj.stderr or "") ~= "" and vim.trim(obj.stderr) or "wt list failed"
	end

	local ok, data = pcall(vim.json.decode, vim.trim(obj.stdout or ""))
	if not ok then
		return nil, "failed to parse wt output: " .. tostring(data)
	end
	return extract_items(data)
end

---@param item table raw item from `wt list --format=json`
---@return internal.git.worktrunk.Item
local function to_item(item)
	local util = require("worktrunk.util")
	local branch = item.branch or "?"
	-- schema 2 nests the path under `worktree`, schema 1 keeps it top-level
	local path = (item.worktree and item.worktree.path) or item.path

	return {
		text = table.concat({ branch, util.commit_message(item) }, " "),
		branch = branch,
		path = path,
		file = path,
		dir = path ~= nil,
		current = util.is_current(item),
		main = util.is_main(item),
		created = path ~= nil,
		previous = item.is_previous or (item.worktree and item.worktree.previous) or false,
		-- schema 2: `remote` is the remote name of a remote-only branch;
		-- schema 1: `remote` is the upstream object of a worktree row.
		remote = type(item.remote) == "string" and item.remote or nil,
		pr = item.ci and item.ci.source == "pr" and item.ci.number or nil,
		worktrunk = item,
	}
end

--- Rank: current worktree, then other worktrees, then local branches without a
--- worktree, then remote-only branches.
---@param item internal.git.worktrunk.Item
---@return integer
local function rank(item)
	if item.current then
		return 0
	elseif item.created then
		return item.main and 1 or 2
	elseif not item.remote then
		return 3
	end
	return 4
end

--- `wt switch` shortcuts, typed as a prefix in the picker input:
---
---   `@`      current worktree
---   `^`      default branch
---   `-`      previous worktree
---   `pr:{N}` / `mr:{N}` PR/MR rows (all of them when `{N}` is omitted)
---
--- The rest of the pattern keeps fuzzy-matching as usual.
---@param pattern string
---@return internal.git.worktrunk.Kind? kind, integer? number, string rest
local function parse_pattern(pattern)
	local number, rest = pattern:match("^[pm]r:(%d*)%s*(.*)$")
	if number then
		return "pr", tonumber(number), rest
	end

	rest = pattern:match("^[pm]r%s+(.*)$") or (pattern:match("^[pm]r$") and "")
	if rest then
		return "pr", nil, rest
	end

	local sigil
	sigil, rest = pattern:match("^([@%^%-])%s*(.*)$")
	if sigil == "@" then
		return "current", nil, rest
	elseif sigil == "^" then
		return "main", nil, rest
	elseif sigil == "-" then
		return "previous", nil, rest
	end

	return nil, nil, pattern
end

--- Filter hook: strips the sigil off the pattern before the matcher sees it and
--- stashes it in `filter.meta`. Returning `true` forces the finder to re-run so
--- the row set follows the sigil (cheap: `wt list` output is cached).
---@param picker snacks.Picker
---@param filter snacks.picker.Filter
---@return boolean refresh
local function transform(picker, filter)
	local opts = picker.opts --[[@as internal.git.worktrunk.Config]]
	local state = assert(opts.wt_state)
	local kind, number, rest = parse_pattern(filter.pattern)

	filter.pattern = rest
	filter.meta.wt_kind = kind
	filter.meta.wt_number = number

	local changed = state.kind ~= kind
	state.kind = kind
	return changed
end

---@param item internal.git.worktrunk.Item
---@param kind? internal.git.worktrunk.Kind
---@param number? integer
---@return boolean
local function matches_kind(item, kind, number)
	if kind == "current" then
		return item.current
	elseif kind == "main" then
		return item.main
	elseif kind == "previous" then
		return item.previous
	elseif kind == "pr" then
		return item.pr ~= nil and (number == nil or item.pr == number)
	end
	return true
end

--- Async finder: `wt list` is a `vim.system` job, so suspend the picker task
--- until its callback fires.
---
--- Unlike `worktrunk.worktree.list()` this passes `--branches`/`--remotes` so
--- branches without a worktree show up too (same set as `wt switch`).
---@param opts internal.git.worktrunk.Config
---@param ctx snacks.picker.finder.ctx
---@return snacks.picker.finder.result
local function finder(opts, ctx)
	local state = assert(opts.wt_state)
	local kind, number = ctx.filter.meta.wt_kind, ctx.filter.meta.wt_number

	-- PR/MR numbers only come with `--full` (forge lookups), so pay for them
	-- lazily, when a `pr:`/`mr:` sigil is typed.
	local mode = kind == "pr" and "full" or "basic"
	local items = state.cache[mode]

	if not items then
		local args = {}
		if opts.branches ~= false then
			args[#args + 1] = "--branches"
		end
		if opts.remotes ~= false then
			args[#args + 1] = "--remotes"
		end
		if mode == "full" then
			args[#args + 1] = "--full"
		end

		local found, err = list(args)
		if not found then
			require("worktrunk.ui").error("worktrunk: " .. tostring(err))
			return {}
		end
		items = found
		state.cache[mode] = items
	end

	---@type internal.git.worktrunk.Item[]
	local entries = {}
	for _, item in ipairs(items) do
		local entry = to_item(item)
		if matches_kind(entry, kind, number) then
			entry.idx = #entries + 1
			entries[#entries + 1] = entry
		end
	end

	-- stable sort: created worktrees first, keeping `wt list` order inside each
	-- group.
	table.sort(entries, function(a, b)
		local ra, rb = rank(a), rank(b)
		if ra ~= rb then
			return ra < rb
		end
		return a.idx < b.idx
	end)

	for i, entry in ipairs(entries) do
		if entry.current then
			ctx.picker.list:set_target(i)
			break
		end
	end

	return entries
end

--- Line counts to show: uncommitted changes for a worktree, otherwise the diff
--- against the default branch.
---@param raw table
---@return integer added, integer deleted
local function diffstat(raw)
	local d = (raw.worktree and raw.worktree.changes and raw.worktree.changes.diff)
		or (raw.working_tree and raw.working_tree.diff)
		or (raw.main and raw.main.diff)
		or (raw.default_branch and raw.default_branch.diff)
	return d and d.added or 0, d and d.deleted or 0
end

--- Columns: gutter sigil, created/not icon, branch, diffstat, commit sha.
---@param item internal.git.worktrunk.Item
---@return snacks.picker.Highlight[]
local function format(item)
	local util = require("worktrunk.util")
	local a = Snacks.picker.util.align
	local raw = item.worktrunk
	local added, deleted = diffstat(raw)

	---@type snacks.picker.Highlight[]
	local ret = {}
	ret[#ret + 1] = { a(util.gutter(raw), 2), item.current and "SnacksPickerGitBranchCurrent" or "SnacksPickerComment" }
	ret[#ret + 1] = {
		a(item.created and icons.created or icons.uncreated, 2),
		item.created and hl.created or hl.uncreated,
	}
	ret[#ret + 1] = { " " }
	ret[#ret + 1] = { a(item.branch, 40, { truncate = true }), "SnacksPickerGitBranch" }
	ret[#ret + 1] = { " " }
	ret[#ret + 1] = { a(added > 0 and ("+%d"):format(added) or "", 7), hl.added }
	ret[#ret + 1] = { a(deleted > 0 and ("-%d"):format(deleted) or "", 7), hl.deleted }
	ret[#ret + 1] = { a(util.sha(raw), 8), "SnacksPickerGitCommit" }
	return ret
end

--- Drop the cached `wt list` output so the next find re-runs the command.
---@param picker snacks.Picker
local function invalidate(picker)
	local state = (picker.opts --[[@as internal.git.worktrunk.Config]]).wt_state
	if state then
		state.cache = {}
	end
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
				invalidate(picker)
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
	--- Switch to the row under the cursor. Rows without the folder icon have no
	--- worktree yet (local or remote branch); `wt switch` creates it on demand.
	worktrunk_switch = function(picker, item)
		picker:close()
		if not item then
			return
		end
		if not item.created then
			require("worktrunk.ui").notify("Creating worktree " .. item.branch)
		end
		require("worktrunk").switch(item.branch)
	end,

	--- Remove every selected worktree (or the one under the cursor), with a
	--- single confirmation for the whole batch.
	worktrunk_remove = function(picker)
		local items = vim.tbl_filter(function(item)
			return item.created
		end, picker:selected({ fallback = true }))
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

	--- Create a worktree for a *new* branch named after the typed text (like
	--- `Alt-c` in the `wt switch` picker). Falls back to worktrunk's own prompt
	--- when the input is empty.
	worktrunk_create = function(picker)
		local _, _, rest = parse_pattern(vim.trim(picker.input.filter.pattern))
		local branch = vim.trim(rest)
		picker:close()

		if branch == "" then
			return require("worktrunk").create()
		end

		require("worktrunk.worktree").create(branch, {}, function(err)
			local ui = require("worktrunk.ui")
			if err then
				ui.error(("worktrunk: %s: %s"):format(branch, err.message))
			else
				ui.notify("Created worktree " .. branch)
			end
		end)
	end,

	--- Re-run `wt list` (pick up worktrees created elsewhere).
	worktrunk_refresh = function(picker)
		invalidate(picker)
		picker:refresh()
	end,
}

--- Open the worktrunk picker.
---@param opts? internal.git.worktrunk.Config
function M.pick(opts)
	local ok = pcall(require, "snacks")
	if not ok then
		return require("worktrunk").list()
	end

	set_highlights()

	return Snacks.picker.pick(vim.tbl_deep_extend("force", {
		source = "worktrunk",
		title = "Worktrees",
		branches = true,
		remotes = true,
		wt_state = { cache = {} },
		filter = { transform = transform },
		finder = finder,
		format = format,
		preview = "none",
		live = false,
		sort = { fields = { "score:desc", "idx" } },
		layout = {
			preset = "select",
			layout = {
				-- NOTE: width/height are fractions of the editor, but min_*/max_*
				-- are absolute columns/lines (`snacks.win` clamps with them).
				width = 0.8,
				min_width = 100,
				max_width = 160,
				height = 0.7,
				min_height = 20,
				max_height = 40,
			},
		},
		confirm = "worktrunk_switch",
		actions = actions,
		win = {
			input = {
				keys = {
					["<C-d>"] = { "worktrunk_remove", mode = { "n", "i" } },
					["<C-n>"] = { "worktrunk_create", mode = { "n", "i" } },
					["<C-r>"] = { "worktrunk_refresh", mode = { "n", "i" } },
				},
			},
			list = {
				keys = {
					["<C-d>"] = "worktrunk_remove",
					["<C-n>"] = "worktrunk_create",
					["<C-r>"] = "worktrunk_refresh",
				},
			},
		},
	}, opts or {}))
end

return M
