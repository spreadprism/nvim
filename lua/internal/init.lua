---@alias NvimEvent "DeferredUIEnter"|vim.api.keyset.events|vim.api.keyset.events[]

-- HACK: this is to help lua-ls find out the types
local old_keys = {}
for k, _ in pairs(_G) do
	table.insert(old_keys, k)
end

local M = {}

--
_G.plugin = require("internal.loader.plugin").plugin
_G.k = require("internal.loader.keymaps")
_G.lsp = require("internal.loader.lsp").lsp
_G.formatter = require("internal.loader.formatter").formatter
_G.linter = require("internal.loader.linter").linter

-- funcs
function _G.get_width(modifier)
	---@diagnostic disable-next-line: deprecated
	return vim.fn.floor(tonumber(vim.api.nvim_command_output("echo &columns")) * (modifier or 1))
end

function _G.get_height(modifier)
	---@diagnostic disable-next-line: deprecated
	return vim.fn.floor(tonumber(vim.api.nvim_command_output("echo &lines")) * (modifier or 1))
end

function _G.plugin_loaded(name)
	return require("lze").state(name) == false
end

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
	warning = "",
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
