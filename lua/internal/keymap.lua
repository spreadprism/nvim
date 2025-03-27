local M = {}

---@class Keymap
---@field plugin? Plugin
---@field group? string
Keymap = {}
Keymap.__index = Keymap

---@param mode string | string[]
---@param lhs string
---@param rhs string | function
---@param description? string
function Keymap:set(mode, lhs, rhs, description)
	local opts = { desc = description }
	if self.plugin == nil then
		local ok, msg = pcall(vim.keymap.set, mode, lhs, rhs, opts)
		if not ok then
			print("failed to set keymap (" .. lhs .. ") => " .. msg)
		end
	else
		self.plugin:keys({
			{ lhs, rhs, desc = description, mode = mode },
		})
	end
end

---@param cmd string
function Keymap:cmd(cmd)
	return function()
		vim.cmd(cmd)
	end
end

M.Keymap = Keymap

return M
