local M = {}

---@class Keymap
---@field plugin? Plugin
---@field group? string
---@field mode string | string[]
---@field key string
---@field action string | function
---@field desc? string
Keymap = {}
Keymap.__index = Keymap

function Keymap:load()
	local opts = { desc = self.desc }
	local ok, msg = pcall(vim.keymap.set, self.mode, self[1], self[2], opts)
	if not ok then
		print("failed to set keymap (" .. self.key .. ") => " .. msg)
	end
end

---@return Keymap
---@param mode string | string[]
---@param key string
---@param action string | function
---@param desc? string
function M.keymap(mode, key, action, desc)
	return setmetatable({ key, action, desc = desc, mode = mode }, Keymap)
end

---@param cmd string
---@param silence? boolean
function M.keymapCmd(cmd, silence)
	if silence == nil then
		silence = false
	end
	return function()
		if silence then
			pcall(vim.cmd, cmd)
		else
			vim.cmd(cmd)
		end
	end
end

---@param keys Keymap | Keymap[]
function M.load_all(keys)
	if type(keys) == "table" and keys.mode then
		keys:load()
	else
		for _, key in ipairs(keys) do
			key:load()
		end
	end
end

---@param key string
---@param desc string
---@param keys Keymap | Keymap[]
---@return Keymap[]
function M.keymap_group(key, desc, keys)
	if keys.mode then
		keys = { keys }
	end
	local new_keys = {}
	for _, k in ipairs(keys) do
		local nk = {
			key .. k[1],
			k[2],
			desc = k.desc,
			mode = k.mode,
		}
		table.insert(new_keys, nk)
	end

	require("which-key").add({ key, group = desc })
	require("which-key").add(new_keys)
	return new_keys
end

return M
