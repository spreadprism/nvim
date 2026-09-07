--- Low level helpers to draw inside PI's tool blocks.
local M = {}

---@alias PiChunk { [1]: string, [2]: string? } text, highlight group
---@alias PiRow { glyph: string?, chunks: PiChunk[] }

--- Flatten a tool result into plain text.
--- `result.content` is either a string, or a list of `{ type = "text", text }`
--- blocks / plain strings.
---@param result table?
---@return string?
function M.result_text(result)
	local content = result and result.content

	if type(content) == "string" then
		local trimmed = vim.trim(content)
		return trimmed ~= "" and trimmed or nil
	end

	if type(content) ~= "table" then
		return nil
	end

	local parts = {}
	for _, block in ipairs(content) do
		if type(block) == "string" then
			parts[#parts + 1] = block
		elseif type(block) == "table" and block.type == "text" and type(block.text) == "string" then
			parts[#parts + 1] = block.text
		end
	end

	local text = vim.trim(table.concat(parts, "\n"))
	return text ~= "" and text or nil
end

---@param url string
---@return string
function M.pretty_url(url)
	return (url:gsub("^https?://", ""):gsub("/+$", ""))
end

---@param text string
---@param width integer
---@return string
function M.truncate(text, width)
	if width <= 1 or vim.fn.strdisplaywidth(text) <= width then
		return text
	end

	local cut = width - 1
	while cut > 0 and vim.fn.strdisplaywidth(text:sub(1, cut)) > cut do
		cut = cut - 1
	end

	return text:sub(1, cut) .. "…"
end

--- Usable text width inside a tool block (window width minus the gutter glyph).
---@param history table pi.ChatHistory
---@return integer
function M.body_width(history)
	local win = vim.fn.win_findbuf(history:buf())[1]
	local width = win and vim.api.nvim_win_get_width(win) or 80
	return math.max(20, width - 6)
end

--- Append/insert rows into a tool block, with the border glyph and per-chunk
--- highlights. Mirrors the plugin's private `render_body_line` / `render_output`.
---@param history table pi.ChatHistory
---@param rows PiRow[]
---@param insert_at integer?
---@return integer? next_insert_at
function M.rows(history, rows, insert_at)
	local tools = require("pi.ui.chat.tools")
	local lines = {}

	for i, row in ipairs(rows) do
		local parts = {}
		for _, chunk in ipairs(row.chunks) do
			parts[#parts + 1] = tools.sanitize_text(chunk[1])
		end
		lines[i] = table.concat(parts)
	end

	local start
	if insert_at then
		start, insert_at = history:_insert_lines(insert_at, lines)
	else
		start = history:_append_lines(lines)
	end

	local buf, ns = history:buf(), history:ns()

	for i, row in ipairs(rows) do
		local line = start + i - 1
		tools.set_border(history, line, row.glyph or tools.GLYPHS.MID)

		local col = 0
		for _, chunk in ipairs(row.chunks) do
			local len = #tools.sanitize_text(chunk[1])
			if chunk[2] and len > 0 then
				vim.api.nvim_buf_set_extmark(buf, ns, line, col, {
					end_col = col + len,
					hl_group = chunk[2],
					priority = 200,
				})
			end
			col = col + len
		end
	end

	return insert_at
end

--- Fallback: dump raw result text as a normal output section.
---@param history table pi.ChatHistory
---@param text string
---@param hl string
---@param insert_at integer?
---@return integer? next_insert_at
function M.raw_output(history, text, hl, insert_at)
	local tools = require("pi.ui.chat.tools")
	local rows = { { glyph = tools.GLYPHS.SEP, chunks = { { "" } } } }
	local fences = 0

	for _, line in ipairs(vim.split(text, "\n", { plain = true })) do
		if line:match("^```") then
			fences = fences + 1
		end
		rows[#rows + 1] = { chunks = { { line, hl } } }
	end

	-- unbalanced fences would style the rest of the buffer as a code block
	if fences % 2 == 1 then
		rows[#rows + 1] = { chunks = { { "```", hl } } }
	end

	return M.rows(history, rows, insert_at)
end

return M
