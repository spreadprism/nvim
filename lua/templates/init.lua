---File templates: LuaSnip skeletons expanded into empty files on BufEnter.
---
---BufEnter + an emptiness check is used rather than BufNewFile: BufNewFile only
---fires for files that do not exist on disk, so files created through oil.nvim
---(which writes them out before you open them) would never be templated.
---
---There is no per-buffer "already checked" bookkeeping: any empty buffer that
---matches a template gets it, every time it is entered. Expanding makes the
---buffer non-empty, which is what stops it from happening twice.
---
---Every *.lua file under lua/templates/ (except this dispatcher) must return a
---template.Entry[]. Template files are loaded with loadfile (NOT require: names
---like "main.go.lua" are unrequireable) and are NEVER registered with LuaSnip,
---so they can never appear in completion; they are expanded exclusively via
---ls.snip_expand().
---
---Winner selection: highest detect() score wins. Ties: first-loaded entry wins
---(files sorted alphabetically by path, array order within a file).
---
---Score convention:
---   10  extension/filetype-generic match (e.g. any *.go)
---   50  exact filename match (e.g. main.go)
---  100  exact filename + project-context evidence (e.g. main.go + ancestor go.mod)

---@class template.Ctx
---@field buf integer buffer the template would expand into (current at expansion time)
---@field path string absolute, normalized file path (primary detection key)
---@field fname string vim.fs.basename(path)
---@field dir string vim.fs.dirname(path)
---@field ft string filename-based filetype (vim.filetype.match({ filename = path }) or "")

---@class template.Entry
---@field detect fun(path: string, ctx: template.Ctx): number|false|nil positive number = score; nil/false/<=0 = no match
---@field snippet table LuaSnip snippet; author with { trig = "tmpl.<lang>.<name>", hidden = true }
---@field desc? string label used in warnings

local M = {}

---@type template.Entry[]|nil
local entries = nil

---entries whose detect() already errored (warn once each)
---@type table<template.Entry, boolean>
local warned = {}

local function warn(msg)
	vim.notify("[templates] " .. msg, vim.log.levels.WARN)
end

---@return template.Entry[]
local function load_entries()
	if entries then
		return entries
	end
	entries = {}

	local root = vim.fs.joinpath(nixcats.configDir, "lua", "templates")
	local dispatcher = vim.fs.joinpath(root, "init.lua")

	local paths = vim.fs.find(function(name, _)
		return name:sub(-4) == ".lua"
	end, { path = root, type = "file", limit = math.huge })
	table.sort(paths)

	for _, path in ipairs(paths) do
		if path ~= dispatcher then
			local chunk, load_err = loadfile(path)
			if not chunk then
				warn(("failed to load %s: %s"):format(path, load_err))
			else
				local ok, list = pcall(chunk)
				if not ok or type(list) ~= "table" then
					warn(("bad template file %s: %s"):format(path, ok and "did not return a table" or list))
				else
					for i, entry in ipairs(list) do
						local valid = type(entry) == "table"
							and type(entry.detect) == "function"
							and type(entry.snippet) == "table"
						if valid then
							entry.desc = entry.desc or ("%s#%d"):format(path, i)
							table.insert(entries, entry)
						else
							warn(("invalid entry %d in %s (need detect=function, snippet=table)"):format(i, path))
						end
					end
				end
			end
		end
	end

	return entries
end

---Run detection over all templates and expand the winner into `buf`.
---Must only be called while `buf` is the current buffer.
---@param buf integer
function M.check(buf)
	local path = vim.fs.normalize(vim.api.nvim_buf_get_name(buf))
	---@type template.Ctx
	local ctx = {
		buf = buf,
		path = path,
		fname = vim.fs.basename(path),
		dir = vim.fs.dirname(path),
		ft = vim.filetype.match({ filename = path }) or "",
	}

	---@type { entry: template.Entry, score: number }|nil
	local best = nil
	for _, entry in ipairs(load_entries()) do
		local ok, score = pcall(entry.detect, path, ctx)
		if not ok then
			if not warned[entry] then
				warned[entry] = true
				warn(("detect failed for %s: %s"):format(entry.desc, score))
			end
		elseif type(score) == "number" and score > 0 and (best == nil or score > best.score) then
			-- strict `>` keeps the first-loaded entry on ties
			best = { entry = entry, score = score }
		end
	end

	if not best then
		return
	end

	-- the cursor may sit past EOL even in an empty buffer (virtual column)
	vim.api.nvim_win_set_cursor(0, { 1, 0 })
	-- deepcopy: snippet objects are stateful and mutated by expansion
	local ok, err = pcall(require("luasnip").snip_expand, vim.deepcopy(best.entry.snippet))
	if not ok then
		warn(("expansion failed for %s: %s"):format(best.entry.desc, err))
	end
end

---Create the BufEnter autocmd. Called from luasnip's `:after` hook, so
---luasnip is guaranteed loaded before any expansion can happen.
function M.setup()
	vim.api.nvim_create_autocmd("BufEnter", {
		group = vim.api.nvim_create_augroup("FileTemplates", { clear = true }),
		pattern = "*",
		callback = function(args)
			local buf = args.buf
			-- BufEnter fires constantly: keep the guards cheap and ordered.
			if vim.bo[buf].buftype ~= "" then
				return
			end
			if vim.api.nvim_buf_get_name(buf) == "" then
				return
			end
			if not vim.bo[buf].modifiable or vim.bo[buf].readonly then
				return
			end

			vim.schedule(function()
				-- snip_expand needs the target buffer to be the current one
				if not vim.api.nvim_buf_is_valid(buf) or vim.api.nvim_get_current_buf() ~= buf then
					return
				end
				-- emptiness is the only gate: template whenever the buffer is
				-- empty and something matches, never clobber existing content
				local non_empty = vim.api.nvim_buf_line_count(buf) > 1
					or vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] ~= ""
				if non_empty then
					return
				end
				M.check(buf)
			end)
		end,
	})
end

return M
