local K = {}

---@class KeymapOpts: vim.keymap.set.Opts
---@field cond? fun()|boolean
---@field hidden? boolean
---@field icon? string|wk.Icon|fun():(wk.Icon|string)

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
function K.Keymap:cond(cond)
	self.spec.cond = cond
end

function K.Keymap:hidden()
	self.spec.hidden = true
end

---@param icon string|wk.Icon|fun():(wk.Icon|string)
function K.Keymap:icon(icon)
	self.spec.icon = icon
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

return K
