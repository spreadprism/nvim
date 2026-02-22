---@alias NvimEvent "DeferredUIEnter"|vim.api.keyset.events|vim.api.keyset.events[]

-- HACK: this is to help lua-ls find out the types
local old_keys = {}
for k, _ in pairs(_G) do
	table.insert(old_keys, k)
end

local M = {}

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

_G.event = require("internal.events")

-- core loaders
_G.plugin = require("internal.loader.plugin").plugin
_G.lsp = require("internal.loader.lsp").lsp
_G.k = require("internal.loader.keymaps")
-- plugin loaders
_G.formatter = require("internal.loader.formatter")
_G.linter = require("internal.loader.linter")
_G.d = require("internal.loader.dap")
-- others
_G.workspace = require("internal.workspace")
_G.env = vim.env

require("internal.direnv")
require("internal.symbols")

for k, v in pairs(_G) do
	if not vim.tbl_contains(old_keys, k) then
		M[k] = v
	end
end

_G.internal = M

return M
