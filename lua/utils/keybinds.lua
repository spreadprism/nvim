local M = {}

local register_keybind = function(mode, key, action, description, opts, force_api)
	force_api = force_api or false

	opts.desc = description

	if
		not pcall(function()
			if force_api then
				vim.api.nvim_set_keymap(mode, key, action, opts)
			else
				vim.keymap.set(mode, key, action, opts)
			end
		end)
	then
		vim.notify(
			"Failed to register keybind, invalid mode: " .. mode .. " => " .. key,
			vim.log.levels.WARNING,
			{ title = "Keybinds" }
		)
	end
end

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
			register_keybind(mode, self.key, self.action, self.description, self.opts, self.force_api)
		end
	elseif type(self.mode) == "string" then
		register_keybind(self.mode, self.key, self.action, self.description, self.opts, self.force_api)
	end
end

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

local keybind_groups_registed_before_whichkey = {}

M.get_groups = function()
	return keybind_groups_registed_before_whichkey
end

function KeybindGroup:register(keybinds)
	keybinds = keybinds or {}
	for _, keybind in ipairs(self.keybinds) do
		keybind.key = self.prefix .. keybind.key
		keybind:register()
	end
	for _, keybind in ipairs(keybinds) do
		keybind.key = self.prefix .. keybind.key
		keybind:register()
	end
	if self.prefix == "" then
		return
	end
	if pcall(require, "which-key") then
		local wk = require("which-key")
		wk.register({
			[self.prefix] = {
				name = self.description,
			},
		})
	else
		table.insert(keybind_groups_registed_before_whichkey, self)
	end
end

M.Keybind = Keybind.new
M.KeybindGroup = KeybindGroup.new

return M
