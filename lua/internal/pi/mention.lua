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

--- Pick one or more files with the snacks file picker and insert every
--- selected file as an `@mention` in the PI prompt buffer. The picker input
--- always starts in insert mode, even when invoked from normal mode.
function M.pick()
	local ok, snacks = pcall(require, "snacks")
	if not ok then
		vim.notify("snacks is not available", vim.log.levels.WARN)
		return
	end

	local picker = snacks.picker.files({
		confirm = function(self)
			local items = self:selected({ fallback = true })
			self:close()

			local pi = require("pi")
			local sent = false
			for _, item in ipairs(items) do
				local path = snacks.picker.util.path(item)
				if path then
					pi.send_mention({ path = relative(path) }, { focus = false })
					sent = true
				end
			end

			if sent then
				vim.schedule(function()
					pi.focus_chat_prompt()
				end)
			end
		end,
		focus = "input",
	})

	-- opening from normal mode (or from PI's prompt mappings) can leave the
	-- picker input in normal mode; force insert once the layout is up
	vim.schedule(function()
		if picker and picker.input and picker.input.win:valid() then
			picker.input.win:focus()
			vim.cmd("startinsert!")
		end
	end)
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
	vim.api.nvim_create_autocmd("BufEnter", {
		group = vim.api.nvim_create_augroup("PiLastBuffer", { clear = true }),
		callback = function(args)
			local mention = mention_of(args.buf)
			if mention then
				last = mention
			end
		end,
	})
end

--- The mention for the last visited non-PI buffer, as tracked by `M.track()`.
---@return { path: string }|nil
function M.last()
	return last
end

return M
