---@alias NvimEvent "DeferredUIEnter"|vim.api.keyset.events|vim.api.keyset.events[]

-- HACK: this is to help lua-ls find out the types
local old_keys = {}
for k, _ in pairs(_G) do
	table.insert(old_keys, k)
end

local M = {}

-- plugins definition
_G.plugin = require("internal.loader.plugin").plugin
_G.k = require("internal.keymaps")

-- symbols definition
_G.Symbols = {
	modified = "󱇧",
	new_file = "󰝒",
	added = "󰈖",
	copied = "",
	updated = "󰚰",
	deleted = "󰮘",
	readonly = "󰷊",
	error = "",
	warn = "",
	hint = "󰌵",
	info = "",
}

for k, v in pairs(_G) do
	if not vim.tbl_contains(old_keys, k) then
		M[k] = v
	end
end

_G.internal = M

return M
