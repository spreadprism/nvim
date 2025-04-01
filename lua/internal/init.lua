---@class Internal
local M = {}

-- _G.print = vim.print
_G.cwd = vim.fn.getcwd
_G.joinpath = vim.fs.joinpath
_G.exec = function(cmd)
	local handle = io.popen(cmd)
	---@diagnostic disable-next-line: need-check-nil
	local result = handle:read("*a")
	---@diagnostic disable-next-line: need-check-nil
	handle:close()
	return result
end
_G.HOME = os.getenv("HOME")
_G.XDG_CONFIG = os.getenv("XDG_CONFIG_HOME") or joinpath(HOME, ".config")
_G.LUA_PATH = joinpath(nixCats.configDir, "lua")
_G.TEMPLATES_PATH = joinpath(LUA_PATH, "templates")

M.plugin = require("internal.plugin").plugin
M.lsp = require("internal.lsp").lsp
M.formatter = require("internal.formatter").formatter
M.linter = require("internal.linter").linter
M.keymap = require("internal.keymap").keymap
M.keymapCmd = require("internal.keymap").keymapCmd
M.keymapLoad = require("internal.keymap").load_all
M.keymapGroup = require("internal.keymap").keymap_group
M.load_all = require("internal.loader").load_all
M.merge_specs = require("internal.specs").merge
M.telescope = require("internal.telescope")
M.workspace = require("internal.workspace")
M.env = require("internal.env")

M.Symbols = {
	modified = "󱇧 ",
	new_file = "󰝒 ",
	added = "󰈖 ",
	copied = " ",
	updated = "󰚰 ",
	deleted = "󰮘 ",
	readonly = "󰷊 ",
	error = " ",
	warn = " ",
	hint = "󰌵 ",
	info = " ",
}

M.Colors = {
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

M.global_vars = {
	"print",
	"cwd",
	"joinpath",
	"plugin",
	"lsp",
	"keymap",
	"keymapCmd",
	"keymapLoad",
	"keymapGroup",
	"Symbols",
	"Colors",
}

_G.plugin = M.plugin
_G.lsp = M.lsp
_G.formatter = M.formatter
_G.linter = M.linter
_G.keymap = M.keymap
_G.keymapCmd = M.keymapCmd
_G.keymapLoad = M.keymapLoad
_G.keymapGroup = M.keymapGroup
_G.workspace = M.workspace
_G.env = M.env

_G.Symbols = M.Symbols
_G.Colors = M.Colors

---@param cmd string
function M.cmd_on_click(cmd)
	return function(_, mouse_button, _)
		if mouse_button == "l" then
			vim.cmd(cmd)
		end
	end
end

_G.internal = M
