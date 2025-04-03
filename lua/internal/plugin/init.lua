local M = {}

local types = require("internal.plugin.types")
local lze = require("internal.plugin.lze")

M.plugin = types.plugin
M.merge_specs = lze.merge

return M
