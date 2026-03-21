local M = {}

M.adapter = require("internal.loader.dap.adapter").adapter
M.launch = require("internal.loader.dap.launch").launch

return M
