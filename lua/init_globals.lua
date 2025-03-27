print = vim.print
cwd = vim.fn.getcwd
joinpath = vim.fs.joinpath

local function try_load_internal(name)
	local ok, import = pcall(require, "internal." .. name)
	if not ok then
		print("Error loading internal module: " .. name .. " (cause=" .. import)
	end
	return import
end

plugin = try_load_internal("plugin").plugin
lsp = try_load_internal("lsp").lsp
local k = try_load_internal("keymap")
plugin = require("internal.plugin").plugin
lsp = require("internal.lsp").lsp
keymap = require("internal.keymap").keymap
keymapGroup = require("internal.keymap").keymap_group
keymapCmd = require("internal.keymap").keymapCmd
keymapLoad = require("internal.keymap").load_all

Symbols = {
	modified = "󱇧 ",
	new_file = "󰝒 ",
	added = "󰈖 ",
	copied = " ",
	updated = "󰚰 ",
	deleted = "󰮘 ",
	readonly = "󰷊 ",
}

local ok, overseer = pcall(require, "overseer")
if ok then
	Symbols.overseer = overseer.STATUS
else
	Symbols.overseer = {
		RUNNING = "?",
	}
end

-- global colors
Colors = {
	bg = "#202328",
	fg = "#bbc2cf",
	yellow = "#ECBE7B",
	cyan = "#008080",
	darkblue = "#081633",
	green = "#98be65",
	orange = "#FF8800",
	violet = "#a9a1e1",
	magenta = "#c678dd",
	blue = "#51afef",
	red = "#ec5f67",
}
require("global_keymaps")
