local snacks = plugin("snacks")
	:opts({
		image = {
			enabled = true,
		},
		inputs = {
			enabled = true,
		},
		---@type snacks.picker.Config
		picker = {
			main = {
				file = false,
			},
			enabled = true,
			matcher = {
				frecency = true,
			},
			win = {
				input = {
					keys = {
						["<S-CR>"] = { "tab", mode = { "n", "i" } },
					},
				},
			},
			on_show = function(_)
				vim.api.nvim_exec_autocmds("User", { pattern = "PickerOnShowClose" })
			end,
			on_close = function(_)
				vim.api.nvim_exec_autocmds("User", { pattern = "PickerOnShowClose" })
			end,
			sources = {
				files = {
					layout = {
						preset = "select",
					},
				},
				grep = {
					layout = {
						preset = "telescope",
					},
				},
				lines = {
					layout = {
						preset = "ivy_split",
					},
				},
				lsp_symbols = {
					layout = {
						preset = "right",
					},
				},
				lsp_workspace_symbols = {
					layout = {
						preset = "telescope",
					},
				},
			},
		},
	})
	:allow_again(vim.env.PROF)
	:keymaps({
		k:map("n", "<leader><leader>", k:require("snacks.picker").files(), "find files"):hidden(),
		k:map("n", "<M-g>", k:require("snacks.picker").grep(), "grep project"),
		k:map("n", "<M-f>", k:require("snacks.picker").lines(), "find in buffer"),
		k:map("n", "<M-m>", k:require("snacks.picker").marks(), "find marks"),
		k:group("find", "<leader>f", {
			k:map("n", "h", k:require("snacks.picker").highlights(), "highlights"),
			k:map("n", "l", k:require("snacks.picker").resume(), "reopen last search"),
		}),
		k:group("dev", "<leader>=", {
			k:map("n", "p", k:require("snacks.profiler").toggle(), "toggle profile"),
		}),
	})
	:lazy(false)

--- Symbols picker (Onoma-backed) ------------------------------------------
---
--- Extends onoma's `get_symbols` snacks source with:
---   * kind filters: a `/<kind>` token anywhere in the live query keeps only
---     symbols whose kind starts with that prefix (case-insensitive).
---     `/f map`, `map /f`, `/function map` and `map /function` all search
---     "map" restricted to `Function` symbols.
---   * <C-g> refine: `supports_live` enables the default `toggle_live`
---     action, switching the input to a matcher pattern over the current
---     results with field syntax (e.g. `file:lua$`, `kind:Method`), just
---     like the grep picker.
---   * scopes: buffer-only (`Symbols`, <M-s>) or project-wide
---     (`Symbols (workspace)`, <M-S>), toggled inside the picker with <C-w>.

--- Splits `/kind` filter tokens out of a live search query.
---@param search string
---@return string query the search with kind tokens removed
---@return string[]? kinds lowercase kind prefixes, nil when none given
local function parse_kind_filters(search)
	local kinds, words = {}, {}
	for word in search:gmatch("%S+") do
		local kind = word:match("^/(%a*)$")
		if kind then
			table.insert(kinds, kind:lower())
		else
			table.insert(words, word)
		end
	end
	return table.concat(words, " "), #kinds > 0 and kinds or nil
end

--- Whether a symbol kind matches any of the given prefixes.
--- `f` and `function` both match the `Function` kind.
---@param kind? string
---@param prefixes string[]
---@return boolean
local function kind_matches(kind, prefixes)
	kind = tostring(kind or ""):lower()
	for _, prefix in ipairs(prefixes) do
		if kind:sub(1, #prefix) == prefix then
			return true
		end
	end
	return false
end

--- Whether an item file path refers to the target (normalized absolute) file.
---@param file string item file path, absolute or cwd-relative
---@param target string
---@param cwd string
---@return boolean
local function same_file(file, target, cwd)
	if file:sub(1, 1) ~= "/" then
		file = cwd .. "/" .. file
	end
	return file == target
end

--- The (normalized, absolute) file of the buffer the picker was opened from,
--- or nil for unnamed buffers.
---@param ctx snacks.picker.finder.ctx
---@return string?
local function origin_buffer_file(ctx)
	local buf = ctx.filter.current_buf
	if not (buf and vim.api.nvim_buf_is_valid(buf)) then
		return nil
	end
	local name = vim.api.nvim_buf_get_name(buf)
	return name ~= "" and vim.fs.normalize(name) or nil
end

plugin("onoma")
	:event("DeferredUIEnter")
	:opts({
		picker = { "snacks" },
	})
	:after(function()
		local base = Snacks.picker.sources.get_symbols
		if not base then
			vim.notify("onoma did not register its `get_symbols` snacks source", vim.log.levels.WARN)
			return
		end

		---@type snacks.picker.Config
		Snacks.picker.sources.symbols = vim.tbl_extend("force", {}, base, {
			title = "Symbols",
			supports_live = true, -- <C-g> toggles live off to refine results
			workspace = false, -- buffer-only by default, <C-w> toggles scope
			finder = function(opts, ctx)
				local query, kinds = parse_kind_filters(ctx.filter.search or "")

				if kinds then
					-- hand onoma's finder the query stripped of `/kind` tokens
					ctx = ctx:clone()
					ctx.filter = ctx.filter:clone()
					ctx.filter.search = query
				end

				local buf_file = not opts.workspace and origin_buffer_file(ctx) or nil

				local find = base.finder(opts, ctx)
				if type(find) ~= "function" or not (kinds or buf_file) then
					return find
				end

				local cwd = ctx.filter.cwd
				return function(cb)
					return find(function(item)
						if buf_file and not same_file(item.file, buf_file, cwd) then
							return
						end
						if kinds and not kind_matches(item.kind, kinds) then
							return
						end
						cb(item)
					end)
				end
			end,
		})
	end)
	:keymaps({
		k:map("n", "<M-s>", k:require("snacks.picker").symbols({ workspace = true }), "symbols"),
	})
