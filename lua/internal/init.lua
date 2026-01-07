-- HACK: this is to help lua-ls find out the types
local old_keys = {}
for k, _ in pairs(_G) do
	table.insert(old_keys, k)
end

local M = {}

-- Define module variables
_G.plugin = require("internal.loader.plugin").plugin
_G.kmap = require("internal.keymaps").kmap
_G.kgroup = require("internal.keymaps").kgroup
_G.klazy = require("internal.keymaps").klazy

for k, v in pairs(_G) do
	if not vim.tbl_contains(old_keys, k) then
		M[k] = v
	end
end

_G.internal = M

return M
