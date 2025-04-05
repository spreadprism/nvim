-- MIT license, see LICENSE for more details.
-- Extension for nvim-dap-ui
local M = {}

M.winbar = {
	lualine_c = { { "filename", file_status = false, color = { fg = "#c0caf5", bg = "None" } } },
}

M.filetypes = {
	"dap-repl",
	"dapui_console",
	"dapui_watches",
	"dapui_stacks",
	"dapui_breakpoints",
	"dapui_scopes",
}

return M
