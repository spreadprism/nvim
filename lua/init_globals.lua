-- Configs
vim.g.configs = {
	lazy_init = false,
	lua_directory_name = vim.fn.stdpath("config") .. "/lua",
	plugins_directory_name = "plugins",
	configs_directory_name = "configs",
	keybinds_directory_name = "keybinds",
	snippets_directory_name = "snippets",
	templates_directory_name = "templates",
}
-- global funcs
print = vim.print
keybind = require("utils.keybinds").Keybind
keybind_group = require("utils.keybinds").KeybindGroup
plugin = require("utils.plugins_specs").Plugin
lsp = require("utils.lsp").Lsp

Symbols = {
	modified = "󱇧 ",
	new_file = "󰝒 ",
	added = "󰈖 ",
	copied = " ",
	updated = "󰚰 ",
	deleted = "󰮘 ",
	readonly = "󰷊 ",
}
vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "ErrorMsg", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "ErrorMsg", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "ErrorMsg", linehl = "", numhl = "" })
vim.fn.sign_define("DapLogPoint", { text = "", texthl = "DiagnosticSignInfo", linehl = "", numhl = "" })

vim.cmd("highlight DapStoppedSign guifg=#87D285")
vim.fn.sign_define("DapStopped", { text = "", texthl = "DapStoppedSign", linehl = "DapStoppedSign", numhl = "" })

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
-- Symbols
vim.fn.sign_define("DiagnosticSignError", { text = "", texthl = "DiagnosticSignError" })
vim.fn.sign_define("DiagnosticSignWarn", { text = "", texthl = "DiagnosticSignWarn" })
vim.fn.sign_define("DiagnosticSignInfo", { text = "", texthl = "DiagnosticSignInfo" })
vim.fn.sign_define("DiagnosticSignHint", { text = "󰌵", texthl = "DiagnosticSignHint" })

vim.diagnostic.config({
	signs = {
		--support diagnostic severity / diagnostic type name
		text = {
			[vim.diagnostic.severity.ERROR] = " ",
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.HINT] = "󰌵",
			[vim.diagnostic.severity.INFO] = " ",
		},
	},
})

vim.cmd([[highlight DiagnosticUnderlineError guifg=#db4b4b]])
vim.cmd([[highlight DiagnosticUnderlineWarn guifg=#e0af68]])
vim.cmd([[highlight DiagnosticDeprecated guifg=#e0af68]])
vim.cmd([[highlight DiagnosticUnderlineInfo guifg=#0db9d7]])
vim.cmd([[highlight DiagnosticInfo guifg=#0db9d7]])
vim.cmd([[highlight DiagnosticUnderlineInfo guifg=#1abc9c]])
