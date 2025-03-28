---@class Nxim
local M = {}

M.plugin = require("nxim.plugin").plugin
M.lsp = require("nxim.lsp").lsp
M.keymap = require("nxim.keymap").keymap
M.keymapCmd = require("nxim.keymap").keymapCmd
M.keymapLoad = require("nxim.keymap").load_all
M.keymapGroup = require("nxim.keymap").keymap_group
M.load_all = require("nxim.loader").load_all
M.merge_specs = require("nxim.specs").merge

M.Symbols = {
	modified = "󱇧 ",
	new_file = "󰝒 ",
	added = "󰈖 ",
	copied = " ",
	updated = "󰚰 ",
	deleted = "󰮘 ",
	readonly = "󰷊 ",
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

_G.print = vim.print
_G.cwd = vim.fn.getcwd
_G.joinpath = vim.fs.joinpath

_G.plugin = M.plugin
_G.lsp = M.lsp
_G.keymap = M.keymap
_G.keymapCmd = M.keymapCmd
_G.keymapLoad = M.keymapLoad
_G.keymapGroup = M.keymapGroup

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

local buffer_blacklist = {
	"neo-tree filesystem [1]",
	"[dap-repl]",
	"DAP Console",
	"DAP Watches",
	"NeogitStatus",
	"NeogitDiffView",
	"null",
	"DiffviewFilePanel",
	"pods",
}

local buffer_blacklist_contains = {
	"%[CodeCompanion%]",
}

local buffer_extension_blacklist = { "harpoon" }
local buffer_mode_blacklist = { "t" }

function M.cond_buffer_blacklist()
	local current_buffer_mode = vim.api.nvim_get_mode().mode
	local current_buffer_name = vim.fn.expand("%:t")
	local current_buffer_filetype = vim.bo.filetype

	-- INFO: Check if current buffer mode is in the blacklist
	for _, mode in ipairs(buffer_mode_blacklist) do
		if current_buffer_mode == mode then
			return false
		end
	end

	-- INFO: Don't need to check if buffer_name is empty
	if current_buffer_name == "" then
		return false
	end

	-- INFO: Check if current buffer name is in the blacklist
	for _, buffer_name in ipairs(buffer_blacklist) do
		if current_buffer_name == buffer_name then
			return false
		end
	end

	-- INFO: Check if current buffer name contains a blacklist
	for _, buffer_name in ipairs(buffer_blacklist_contains) do
		if string.find(current_buffer_name, buffer_name) then
			return false
		end
	end

	-- INFO: Check if current buffer extension is in the blacklist
	for _, buffer_extension in ipairs(buffer_extension_blacklist) do
		if current_buffer_filetype == buffer_extension then
			return false
		end
	end

	return true
end

return M
