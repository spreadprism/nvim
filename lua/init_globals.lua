print = vim.print

LUA_DIRECTORY_PATH = vim.fn.stdpath("config") .. "/lua"
NVIM_SHARE_DIRECTORY = vim.fn.stdpath("data")

MASON_DIR = vim.fs.joinpath(NVIM_SHARE_DIRECTORY, "mason")
LAZY_DIR = vim.fs.joinpath(NVIM_SHARE_DIRECTORY, "lazy")

PLUGINS_PATH = vim.fs.joinpath(LUA_DIRECTORY_PATH, "plugins")
CONFIGS_PATH = vim.fs.joinpath(LUA_DIRECTORY_PATH, "configs")
KEYBINDS_PATH = vim.fs.joinpath(LUA_DIRECTORY_PATH, "keybinds")

vim.g.format_ft = {}

plugin = require("internal.lazy_specs").plugin
rock = require("internal.lazy_specs").rock
keybind = require("internal.keybinds").keybind
keybind_group = require("internal.keybinds").keybind_group
lsp = require("internal.lsp").lsp
dap = require("internal.dap").adapter
launch_configs = require("internal.dap").launch_configs
formatter = require("internal.formatting").formatter
linter = require("internal.linting").linter

state = require("internal.state")

Symbols = {
	modified = "󱇧 ",
	new_file = "󰝒 ",
	added = "󰈖 ",
	copied = " ",
	updated = "󰚰 ",
	deleted = "󰮘 ",
	readonly = "󰷊 ",
}
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
