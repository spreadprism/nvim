local keybinds = require("internal.keybinds.binds")
local Keybind = {}
Keybind.__index = Keybind

function Keybind.new(mode, key, action, description, opts, force_api)
	local self = setmetatable({}, Keybind)
	self.mode = mode or "n"
	self.key = key or nil
	self.action = action or nil
	self.description = description or ""
	self.opts = opts or {}
	self.force_api = force_api or false
	return self
end

function Keybind:register()
	if type(self.mode) == "table" then
		for _, mode in ipairs(self.mode) do
			keybinds.register_keybind(mode, self.key, self.action, self.description, self.opts, self.force_api)
		end
	elseif type(self.mode) == "string" then
		keybinds.register_keybind(self.mode, self.key, self.action, self.description, self.opts, self.force_api)
	end
end

return Keybind.new
