local M = {}

M.lsp = require("internal.lsp.configs")
M.mason = require("internal.lsp.utils").all_lsp_mason
M.get_display = require("internal.lsp.utils").get_display
M.configure_all_lsp = require("internal.lsp.utils").configure_all_lsp

return M
