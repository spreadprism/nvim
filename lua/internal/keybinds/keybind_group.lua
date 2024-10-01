local utils = require("internal.keybinds.utils")
local KeybindGroup = {}
KeybindGroup.__index = KeybindGroup

function KeybindGroup.new(prefix, description, keybinds)
	local self = setmetatable({}, KeybindGroup)
	self.prefix = prefix or ""
	self.description = description or ""
	self.keybinds = keybinds or {}
	for _, keybind in ipairs(self.keybinds) do
		if type(keybind) == "Keybind" then
			table.insert(self.keybinds, keybind)
		end
	end
	return self
end

function KeybindGroup:register(keybinds)
	keybinds = keybinds or {}
	for _, keybind in ipairs(self.keybinds) do
		if keybind.key == nil then
			keybind.prefix = self.prefix .. keybind.prefix
		else
			keybind.key = self.prefix .. keybind.key
		end
		keybind:register()
	end
	for _, keybind in ipairs(keybinds) do
		if keybind.key == nil then
			keybind.prefix = self.prefix .. keybind.prefix
		else
			keybind.key = self.prefix .. keybind.key
		end
		keybind:register()
	end
	if self.prefix == "" then
		return
	end
	if pcall(require, "which-key") then
		local wk = require("which-key")
		wk.add({
			self.prefix,
			group = self.description,
		})
	else
		utils.insert_group(self)
	end
end

return KeybindGroup.new
