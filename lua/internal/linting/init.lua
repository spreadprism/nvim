local M = {}

M.linter = require("internal.linting.linter")
M.mason = require("internal.linting.utils").list_linters_mason
M.list_linters = require("internal.linting.utils").list_linters

return M
