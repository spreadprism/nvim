local M = {}

M.winbar = {
	lualine_c = { { "filename", file_status = false, color = { fg = "#c0caf5", bg = "None" } } },
}

M.filetypes = require("internal.dap_ui").dap_ui_ft
return M
