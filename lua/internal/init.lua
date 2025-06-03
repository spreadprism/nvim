---@class Internal
local M = {}

-- _G.print = vim.print
_G.cwd = vim.fn.getcwd
_G.joinpath = vim.fs.joinpath
_G.exec = function(cmd)
	local handle, err = io.popen(cmd)
	---@type string
	---@diagnostic disable-next-line: need-check-nil
	local result = handle:read("*a")
	---@diagnostic disable-next-line: need-check-nil
	handle:close()

	return result:gsub("\n$", ""), err
end
_G.HOME = os.getenv("HOME")
_G.XDG_CONFIG = os.getenv("XDG_CONFIG_HOME") or joinpath(HOME, ".config")
_G.LUA_PATH = joinpath(nixCats.configDir, "lua")
_G.TEMPLATES_PATH = joinpath(LUA_PATH, "templates")

M.plugin = require("internal.plugin").plugin
M.lsp = require("internal.lsp").lsp
M.dap = require("internal.dap").adapter
M.neotest = require("internal.neotest").adapter
M.formatter = require("internal.formatter").formatter
M.linter = require("internal.linter").linter
local keymap = require("internal.keymap")
M.kmap = keymap.keymap
M.kcmd = keymap.cmd
M.klazy = keymap.lazy
M.kgroup = keymap.group
M.kopts = keymap.opts
M.load_all = require("internal.loader").load_all
M.merge_specs = require("internal.plugin.lze").merge
M.workspace = require("internal.workspace")
M.env = require("internal.env")
M.plugin_loaded = function(plugin)
	return require("lze").state(plugin) == false
end

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
	"kcmd",
	"keymapLoad",
	"kgroup",
	"Symbols",
	"Colors",
}

_G.plugin = M.plugin
_G.lsp = M.lsp
_G.dap = M.dap
_G.neotest = M.neotest
_G.formatter = M.formatter
_G.linter = M.linter
_G.kmap = M.kmap
_G.kcmd = M.kcmd
_G.klazy = M.klazy
_G.kgroup = M.kgroup
_G.kopts = M.kopts
_G.workspace = M.workspace
_G.env = M.env

_G.Symbols = M.Symbols
_G.Colors = M.Colors

function _G.get_width(modifier)
	---@diagnostic disable-next-line: deprecated
	return vim.fn.floor(tonumber(vim.api.nvim_command_output("echo &columns")) * (modifier or 1))
end

function _G.get_height(modifier)
	---@diagnostic disable-next-line: deprecated
	return vim.fn.floor(tonumber(vim.api.nvim_command_output("echo &lines")) * (modifier or 1))
end

---@param cmd string
function M.cmd_on_click(cmd)
	return function(_, mouse_button, _)
		if mouse_button == "l" then
			vim.cmd(cmd)
		end
	end
end

_G.internal = M
