local M = {}

--- Park the cursor at the end of the block quick chat just generated.
---
--- The plugin never touches the cursor, exposes no autocmd, and does not hand
--- back the lines it applied. But `apply_raw_code_response` replaces the anchor
--- region in a single `nvim_buf_set_lines`, so the size of the generated block
--- can be recovered from how far the buffer's line count moved.
---@param anchor { buf: integer, win: integer, first_row: integer, last_row: integer, line_count: integer }
local function follow_generated_block(anchor)
	local buf, win = anchor.buf, anchor.win
	if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_win_is_valid(win) then
		return
	end
	-- The anchor rows describe a layout that is no longer on screen.
	if vim.api.nvim_win_get_buf(win) ~= buf then
		return
	end

	local count = vim.api.nvim_buf_line_count(buf)
	local last_row = math.min(anchor.last_row + (count - anchor.line_count), count)
	local first_row = math.max(math.min(anchor.first_row, last_row), 1)
	if last_row < first_row then
		return
	end

	-- Don't yank the cursor back if the user deliberately moved off the block
	-- while the request was in flight.
	local cursor_row = vim.api.nvim_win_get_cursor(win)[1]
	if cursor_row < first_row or cursor_row > last_row then
		return
	end

	-- Land on the last line with content rather than the trailing blank the
	-- plugin leaves behind: `extract_response_text` strips the closing code
	-- fence but not the newline in front of it, and `vim.split` then turns that
	-- newline into a final empty element.
	local lines = vim.api.nvim_buf_get_lines(buf, first_row - 1, last_row, false)
	local target = last_row
	for i = #lines, 1, -1 do
		if lines[i]:match("%S") then
			target = first_row + i - 1
			break
		end
	end

	local line = vim.api.nvim_buf_get_lines(buf, target - 1, target, false)[1] or ""
	pcall(vim.api.nvim_win_set_cursor, win, { target, #line })
end

---@param opts? { prompt?: string, model?: string, agent?: string|fun():string?, follow?: boolean }
function M.quick_chat(opts)
	return function()
		local util = require("opencode.util")
		local mode = vim.fn.mode()

		local range
		if mode:match("[vV\022]") then
			local visual = util.get_visual_range()
			range = visual and { start = visual.start_line, stop = visual.end_line } or nil
		end

		-- Resolve now, not in the callback: `vim.ui.input` defers, by which
		-- point the current buffer/filetype is the input window's.
		local resolved = vim.tbl_extend("force", {}, opts or {})
		local preset = resolved.prompt
		resolved.prompt = nil
		-- Default to following only from insert mode: that is the flow where the
		-- response lands under a cursor that is still mid-typing, and where
		-- leaving the cursor at its stale column is most disruptive.
		local follow = resolved.follow
		resolved.follow = nil
		if follow == nil then
			follow = mode:sub(1, 1) == "i"
		end
		if type(resolved.agent) == "function" then
			resolved.agent = resolved.agent()
		end

		-- Anchored out here for the same reason: by the time `send` runs off the
		-- back of `vim.ui.input`, the current window is the input's, not the one
		-- the response will be written into.
		local anchor
		if follow then
			local win = vim.api.nvim_get_current_win()
			local buf = vim.api.nvim_win_get_buf(win)
			local row = vim.api.nvim_win_get_cursor(win)[1]
			anchor = {
				buf = buf,
				win = win,
				first_row = range and range.start or row,
				last_row = range and range.stop or row,
				line_count = vim.api.nvim_buf_line_count(buf),
			}
		end

		local function send(input)
			if not input or input == "" then
				return
			end
			local prompt, ctx = util.parse_quick_context_args(input)
			resolved.context_config = ctx

			-- The promise resolves only after `on_done` has awaited
			-- `process_response`, so the buffer write has already landed here.
			-- `and_then` dispatches through `vim.schedule`, so it is safe to
			-- attach from this synchronous callback.
			local promise = require("opencode.quick_chat").quick_chat(prompt, resolved, range)
			if anchor and promise then
				promise:and_then(function()
					follow_generated_block(anchor)
				end)
			end
		end

		if preset then
			return send(preset)
		end

		vim.ui.input({ prompt = "Quick Chat Message: ", win = { relative = "cursor" } }, send)
	end
end

return M
