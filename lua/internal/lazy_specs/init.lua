local M = {}

M.plugin = require("internal.lazy_specs.plugin")
M.rock = require("internal.lazy_specs.rock")
M.init_specs = require("internal.lazy_specs.specs").init_plugin_specs
M.get_specs = require("internal.lazy_specs.specs").specs
M.read_configs = require("internal.lazy_specs.utils").load_all_configs

return M
