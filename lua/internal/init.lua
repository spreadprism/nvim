---@alias NvimEvent "DeferredUIEnter"|vim.api.keyset.events|vim.api.keyset.events[]

-- HACK: this is to help lua-ls find out the types
local old_keys = {}
for k, _ in pairs(_G) do
	table.insert(old_keys, k)
end

local M = {}

_G.plugin = require("internal.loader.plugin").plugin
_G.k = require("internal.keymaps")
_G.on = require("internal.on_event")
_G.lsp = require("internal.loader.lsp").lsp

-- symbols definition
_G.Symbols = {
	modified = "󱇧",
	new_file = "󰝒",
	added = "󰝒",
	untracked = "󰡯",
	moved = "󰪹",
	ignored = "󰩋",
	copied = "",
	updated = "󰚰",
	deleted = "󱪡",
	conflict = "󰮘",
	readonly = "󰷊",
	partial_stage = "󰈝",
	error = "",
	warn = "",
	hint = "󰌵",
	info = "",
	separators = {
		angle = {
			left = "",
			right = "",
		},
		splitter = {
			left = "",
			right = "",
		},
	},
}

for k, v in pairs(_G) do
	if not vim.tbl_contains(old_keys, k) then
		M[k] = v
	end
end

_G.internal = M

return M
