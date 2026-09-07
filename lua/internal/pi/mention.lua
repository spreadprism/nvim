local ft = require("internal.pi.ft")

local M = {}

--- Last mention pointing at a non-PI buffer, kept up to date by `M.track()`.
---@type { path: string }|nil
local last = nil

---@param path string
---@return string
local function relative(path)
	local rel = vim.fs.relpath(vim.uv.cwd(), path) or path
	if rel == "" then
		rel = "."
	end
	return rel
end

--- In `oil` buffers mention the entry under the cursor (or the browsed
--- directory when there's none), relative to cwd, instead of the
--- `oil://` buffer path.
---@return { path: string }|nil
function M.oil()
	if vim.bo.filetype ~= "oil" then
		return nil
	end

	local ok, oil = pcall(require, "oil")
	if not ok then
		return nil
	end

	local dir = oil.get_current_dir()
	if not dir then
		return nil
	end

	-- prefer the entry under the cursor, if any
	local entry = oil.get_cursor_entry()
	if entry and entry.name and entry.name ~= ".." then
		dir = (dir:gsub("/+$", "")) .. "/" .. entry.name
	end

	local rel = relative((dir:gsub("/+$", "")))

	return { path = rel }
end

--- Mention for the buffer `buf` points at, or `nil` when it isn't a real file
--- (PI panels, scratch buffers, terminals, ...).
---@param buf integer
---@return { path: string }|nil
local function mention_of(buf)
	if not vim.api.nvim_buf_is_valid(buf) then
		return nil
	end

	local filetype = vim.bo[buf].filetype

	if vim.tbl_contains(ft.panels, filetype) then
		return nil
	end

	if filetype == "oil" then
		return M.oil()
	end

	if vim.bo[buf].buftype ~= "" then
		return nil
	end

	local name = vim.api.nvim_buf_get_name(buf)
	if name == "" or not vim.uv.fs_stat(name) then
		return nil
	end

	return { path = relative(name) }
end

--- Remember the last non-PI buffer so the prompt can mention it later.
function M.track()
	vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
		group = vim.api.nvim_create_augroup("PiLastBuffer", { clear = true }),
		callback = function(args)
			local mention = mention_of(args.buf)
			if mention then
				last = mention
			end
		end,
	})
end

--- The mention for the last visited non-PI buffer, falling back to the
--- alternate file when nothing was tracked yet.
---@return { path: string }|nil
function M.last()
	if last then
		return last
	end

	local alt = vim.fn.bufnr("#")
	if alt > 0 then
		return mention_of(alt)
	end

	return nil
end

return M
