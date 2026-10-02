--- A statusline component showing the position of the cursor in the list of
--- hunks of a diff: `(2/5)`, or `(-/5)` when the cursor sits outside a hunk.

--- hunks, as `{ first, last }` line ranges, keyed by buffer
---@type table<integer, { tick: integer, hunks: integer[][] }>
local cache = {}

vim.api.nvim_create_autocmd({ "DiffUpdated", "BufWipeout" }, {
	group = vim.api.nvim_create_augroup("statusline_diffcount", { clear = true }),
	callback = function(args)
		if args.event == "BufWipeout" then
			cache[args.buf] = nil
		else
			-- a diff update of one buffer invalidates every side of the layout
			cache = {}
		end
	end,
})

--- walk the buffer and group the lines vim highlights as changed.
--- `diff_hlID` is the only view we get on vim's own diff.
---@param winid integer
---@param bufnr integer
---@return integer[][]
local function diff_hunks(winid, bufnr)
	local hunks = {}

	vim.api.nvim_win_call(winid, function()
		local open = nil

		for lnum = 1, vim.api.nvim_buf_line_count(bufnr) do
			if vim.fn.diff_hlID(lnum, 1) > 0 then
				open = open or lnum
			elseif open then
				hunks[#hunks + 1] = { open, lnum - 1 }
				open = nil
			end
		end

		if open then
			hunks[#hunks + 1] = { open, vim.api.nvim_buf_line_count(bufnr) }
		end
	end)

	return hunks
end

--- the `diff1_inline` layout has `diff` off; its hunks live in the renderer
---@param bufnr integer
---@return integer[][]?
local function inline_hunks(bufnr)
	local ok, inline = pcall(require, "diffview.scene.inline_diff")
	if not ok then
		return nil
	end

	local raw = inline.get_hunks(bufnr)
	if not raw then
		return nil
	end

	return vim.tbl_map(function(hunk)
		local start, count = hunk[3], hunk[4]
		return { start, count > 0 and start + count - 1 or start }
	end, raw)
end

---@param winid integer
---@param bufnr integer
---@return integer[][]?
local function hunks_of(winid, bufnr)
	local tick = vim.api.nvim_buf_get_changedtick(bufnr)
	local hit = cache[bufnr]

	if hit and hit.tick == tick then
		return hit.hunks
	end

	local hunks = inline_hunks(bufnr) or (vim.wo[winid].diff and diff_hunks(winid, bufnr))
	if not hunks then
		return nil
	end

	cache[bufnr] = { tick = tick, hunks = hunks }
	return hunks
end

return {
	-- heirline evaluates `condition` before `init`, so the lookup lives here
	condition = function(self)
		local winid = vim.api.nvim_get_current_win()
		local hunks = hunks_of(winid, vim.api.nvim_win_get_buf(winid))

		if not hunks or #hunks == 0 then
			return false
		end

		self.total = #hunks
		self.current = nil

		local line = vim.api.nvim_win_get_cursor(winid)[1]
		for i, hunk in ipairs(hunks) do
			if line >= hunk[1] and line <= hunk[2] then
				self.current = i
				break
			end
		end

		return true
	end,
	update = { "CursorMoved", "DiffUpdated", "BufEnter", "WinEnter", "ModeChanged" },
	provider = function(self)
		return (" (%s/%d) "):format(self.current or "-", self.total)
	end,
	hl = function(self)
		return { fg = self.mode_color(), bold = true }
	end,
}
