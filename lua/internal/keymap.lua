-- TODO: Fix the duplicated keys
local M = {}

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
	if self.opts.buffer ~= nil then
		local new_mode = {}
		for _, mode in ipairs(self.mode) do
			local buffer = self.opts.buffer
			if type(buffer) == "boolean" and buffer then
				buffer = 0
			end

			---@diagnostic disable-next-line: param-type-mismatch
			if not M.buf_has_keymap(buffer, mode, self.keys) then
				table.insert(new_mode, mode)
			end

			self.mode = new_mode
		end
	end
	if #self.mode > 0 then
		require("which-key").add(vim.tbl_deep_extend("force", {
			self.keys,
			self.action,
			mode = self.mode,
		}, self.opts))
	end
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
	-- if v:vim_did_enter

	if vim.fn.exists("v:vim_did_enter") == 1 then
		vim.defer_fn(function()
			keymap:map_which_key()
		end, 100)
	else
		vim.api.nvim_create_autocmd("VimEnter", {
			once = true,
			callback = function()
				keymap:map_which_key()
			end,
		})
	end
	return keymap
end

---@param bufnr? integer
function Keymap:buffer(bufnr)
	bufnr = bufnr or vim.fn.bufnr()
	self.opts.buffer = bufnr
end

---@param opts KeymapOpts
---@param maps Keymap[]
function M.opts(opts, maps)
	---@type Keymap[]
	for _, map in ipairs(maps) do
		map.opts = vim.tbl_deep_extend("error", map.opts or {}, opts)
	end
	return maps
end

local groups_list = {}
---@param keys string
---@param desc string
---@param opts KeymapOpts
---@param maps Keymap[]
function M.group(keys, desc, opts, maps)
	maps = M.opts(opts, maps)

	for _, kmap in ipairs(maps) do
		kmap.keys = keys .. kmap.keys
	end

	if not groups_list[keys .. desc] then
		require("which-key").add({
			---@diagnostic disable-next-line: assign-type-mismatch
			keys,
			group = desc,
		})
		groups_list[keys .. desc] = true
	end

	return unpack(maps)
end

---@param cmd string
---@param ignore_error? boolean
function M.cmd(cmd, ignore_error)
	return function()
		if ignore_error then
			---@diagnostic disable-next-line: param-type-mismatch
			pcall(vim.cmd, cmd)
		else
			vim.cmd(cmd)
		end
	end
end

---@param module string
function M.lazy(module)
	return setmetatable({}, {
		__index = function(_, key)
			return function(...)
				local args = { ... }
				return function()
					-- vim.print(string.format("require(%s).%s(%s)", module, key, table.concat(args, ", ")))
					return require(module)[key](unpack(args))
				end
			end
		end,
	})
end

---@param buffer integer
---@param mode string
---@param ... string
---@return boolean
function M.buf_has_keymap(buffer, mode, ...)
	local keys = { ... }

	local buffer_keys = vim.api.nvim_buf_get_keymap(buffer, mode)
	buffer_keys = vim.tbl_map(function(k)
		return k.lhs
	end, buffer_keys)
	for _, key in ipairs(keys) do
		key = key:gsub("<leader>", vim.g.mapleader):gsub("<localleader>", vim.g.maplocalleader)
		if vim.tbl_contains(buffer_keys, key) then
			return true
		end
	end
	return false
end

function M.buf_del_keymap(buffer, mode, ...)
	local keys = { ... }
	for _, key in ipairs(keys) do
		key = key:gsub("<leader>", vim.g.mapleader):gsub("<localleader>", vim.g.maplocalleader)
		pcall(vim.api.nvim_buf_del_keymap, buffer, mode, key)
	end
end

return M
