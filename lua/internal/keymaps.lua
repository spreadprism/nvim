local K = {}

---@alias KeymapSpec wk.Spec

---@class Keymap
---@field spec KeymapSpec
K.Keymap = {}
K.Keymap.__index = K.Keymap

---@param spec KeymapSpec
local function Keymap(spec)
	return setmetatable({ spec = spec }, K.Keymap)
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

---@param name string
---@param key string
---@param keymaps Keymap | Keymap[]
---@return Keymap
function K:group(name, key, keymaps)
	return Keymap({
		key,
		group = name,
		expand = function()
			if keymaps.__index == K.Keymap then
				keymaps = { keymaps }
			end
			return vim.tbl_map(function(keymap)
				return keymap.spec
			end, keymaps)
		end,
	})
end
---@param keymaps Keymap | Keymap[]
---@return Keymap
function K:opts(keymaps)
	if keymaps.__index == K.Keymap then
		keymaps = { keymaps }
	end
	return Keymap({ unpack(keymaps) })
end

function K:add(keymap)
	if keymap.__index == K.Keymap then
		keymap:add()
	else
		for _, k in ipairs(keymap) do
			K:add(k)
		end
	end
end

K.act = {}

function K.act:cmd(cmd)
	return function()
		vim.cmd(cmd)
	end
end

function K.act:lazy(module)
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
