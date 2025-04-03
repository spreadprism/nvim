-- TODO: Fix the duplicated keys
local M = {}
local UserPassed = false
vim.api.nvim_create_autocmd("User", {
	once = true,
	callback = function()
		UserPassed = true
	end,
})

---@class KeymapOpts: vim.keymap.set.Opts
---@field cond? boolean | fun():boolean
---@field hidden? boolean
---@field map? boolean

---@class Keymap
---@field mode string[]
---@field keys string
---@field action string | function
---@field opts vim.keymap.set.Opts
---@field autocmd integer
Keymap = {}
Keymap.__index = Keymap

function Keymap:map_which_key()
	require("which-key").add(vim.tbl_deep_extend("force", {
		self.keys,
		self.action,
		mode = self.mode,
	}, self.opts))
end

---@param mode string | string[]
---@param keys string
---@param action string | function
---@param desc string
---@param opts? KeymapOpts
---@return Keymap
function M.keymap(mode, keys, action, desc, opts)
	opts = opts or {}
	opts.desc = desc
	if type(mode) == "string" then
		mode = vim.split(mode, "", { trimempty = true })
	end
	local keymap = setmetatable({ mode = mode, keys = keys, action = action, opts = opts }, Keymap)
	if keymap.opts.map or keymap.opts.map == nil then
		if UserPassed then
			vim.schedule(function()
				keymap:map_which_key()
			end)
		else
			vim.api.nvim_create_autocmd("User", {
				once = true,
				callback = function()
					keymap:map_which_key()
				end,
			})
		end
	end
	return keymap
end

---@param bufnr? integer
function Keymap:buffer(bufnr)
	bufnr = bufnr or vim.fn.bufnr()
	self.opts.buffer = bufnr
end

---@generic T : Keymap | Keymap[]
---@param opts KeymapOpts
---@param maps T
---@return T
function M.opts(opts, maps)
	if getmetatable(maps) == Keymap then
		---@type Keymap
		local kmap = maps
		kmap.opts = vim.tbl_deep_extend("error", kmap.opts or {}, opts)
	else
		---@type Keymap[]
		local kmaps = maps
		for _, map in ipairs(kmaps) do
			map.opts = vim.tbl_deep_extend("error", map.opts or {}, opts)
		end
	end
	return maps
end

---@param keys string
---@param desc string
---@param opts KeymapOpts
---@param maps Keymap[]
function M.group(keys, desc, opts, maps)
	maps = M.opts(opts, maps)

	for _, kmap in ipairs(maps) do
		kmap.keys = keys .. kmap.keys
	end
	local map = function()
		require("which-key").add({
			---@diagnostic disable-next-line: assign-type-mismatch
			keys,
			group = desc,
		})
	end

	if UserPassed then
		vim.schedule(function()
			map()
		end)
	else
		vim.api.nvim_create_autocmd("User", {
			callback = function()
				map()
			end,
		})
	end

	return unpack(maps)
end

return M
