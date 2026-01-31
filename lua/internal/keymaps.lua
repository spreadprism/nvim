local K = {}

---@alias KeymapSpec wk.Spec

---@class Keymap
---@field spec KeymapSpec
---@field lazy boolean
K.Keymap = {}
K.Keymap.__index = K.Keymap

---@param spec KeymapSpec
local function Keymap(spec)
	return setmetatable({ spec = spec, lazy = false }, K.Keymap)
end

---@param cond boolean|fun():boolean
---@return Keymap
function K.Keymap:cond(cond)
	self.spec.cond = cond
	return self
end

---@return Keymap
function K.Keymap:hidden()
	self.spec.hidden = true
	return self
end

---@param icon string|wk.Icon|fun():(wk.Icon|string)
---@return Keymap
function K.Keymap:icon(icon)
	self.spec.icon = icon
	return self
end

---@param buffer number
---@return Keymap
function K.Keymap:buffer(buffer)
	self.spec.buffer = buffer
	return self
end

---@param ft string|string[]
---@return Keymap
function K.Keymap:ft(ft)
	self.lazy = true
	vim.api.nvim_create_autocmd("BufEnter", {
		callback = function(args)
			if type(ft) == "string" then
				ft = { ft }
			end
			if vim.tbl_contains(ft, vim.bo[args.buf].filetype) then
				self:buffer(args.buf):add()
			end
		end,
	})
	return self
end

---@return Keymap
function K.Keymap:silent()
	self.spec.silent = true
	return self
end

---@return Keymap
function K.Keymap:noremap()
	self.spec.noremap = true
	return self
end

---@return Keymap
function K.Keymap:nowait()
	self.spec.nowait = true
	return self
end

---@return Keymap
function K.Keymap:expr()
	self.spec.expr = true
	return self
end

---@return Keymap
function K.Keymap:remap()
	self.spec.remap = true
	return self
end

function K.Keymap:add()
	require("which-key").add({ self.spec })
end

---@param mode string | string[]
---@param key string
---@param action string | function
---@param desc string
---@return Keymap
function K:map(mode, key, action, desc)
	if type(mode) == "string" then
		mode = vim.split(mode, "")
	end

	return Keymap({
		key,
		action,
		mode = mode,
		desc = desc,
	})
end

---@param mode string | string[]
---@param key string
function K:del(mode, key)
	if type(mode) == "string" then
		mode = vim.split(mode, "")
	end
	return Keymap({
		key,
		"<Nop>",
		mode = mode,
	})
end

---@param name string
---@param key string
---@param keymaps Keymap | Keymap[]
---@return Keymap
function K:group(name, key, keymaps)
	if keymaps.__index == K.Keymap then
		keymaps = { keymaps }
	end
	return Keymap({
		key,
		group = name,
		unpack(vim.tbl_map(function(keymap)
			keymap.spec[1] = key .. keymap.spec[1]
			return keymap.spec
		end, keymaps)),
	})
end

--- creates a which-key opts table from keymaps
--- allowing the user to apply options to multiple keymaps at once
--- for example k:opts({...}):buffer(5):add() would add the buffer option to all keymaps in the table
---@param keymaps Keymap | Keymap[]
---@return Keymap
function K:opts(keymaps)
	if keymaps.__index == K.Keymap then
		keymaps = { keymaps }
	end
	return Keymap({ unpack(vim.tbl_map(function(map)
		return map.spec
	end, keymaps)) })
end

---@param keymap Keymap | Keymap[]
---@param lazy? boolean Wheter to add lazy keymaps
function K:add(keymap, lazy)
	if keymap.__index == K.Keymap then
		if not keymap.lazy or lazy then
			keymap:add()
		end
	else
		for _, k in ipairs(keymap) do
			K:add(k, lazy)
		end
	end
end

--- Generates a command function for use in keymaps
--- instead of <cmd>SomeCommand<cr>
--- you can do k:cmd("SomeCommand")
---@param cmd string
---@param ignore_error? boolean
function K:cmd(cmd, ignore_error)
	return function()
		if ignore_error then
			---@diagnostic disable-next-line: param-type-mismatch
			pcall(vim.cmd, cmd)
		else
			vim.cmd(cmd)
		end
	end
end

--- TODO: add a way to be recursive, currently can only do k:require("module").foo(...)
--- would like to be able to do k:require("module").submodule.func(...)

--- Generates a lazy loader for a module's functions
--- for example instead of require("module").func(args)
--- you can do k:lazy("module").func(args)
--- @param module string
function K:require(module)
	return setmetatable({}, {
		__index = function(_, key)
			return function(...)
				local args = { ... }
				return function()
					return require(module)[key](unpack(args))
				end
			end
		end,
	})
end

return K
