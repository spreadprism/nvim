local ps_utils = require("utils.plugins_specs")
local fs = require("utils.filesystem")
local plugins_directory_name = "plugins"
local config_lua_dir = vim.fs.joinpath(vim.fn.stdpath("config"), "lua")
local plugins_directory = vim.fs.joinpath(config_lua_dir, plugins_directory_name)

-- INFO: Set the specs to {}
ps_utils.init_lazy_rock_specs()

local plugin_files = vim.tbl_filter(function(file)
	return string.match(file, "[.]lua$")
end, fs.scan_dir(plugins_directory) or {})

for _, file in ipairs(plugin_files) do
	local plugin_module_name = fs.file_name(file)
	local full_module_name = plugins_directory_name .. "." .. plugin_module_name
	local ok, module_result = pcall(require, full_module_name)
	if ok then
		if type(module_result) == "function" then
			module_result = module_result()
		end
		local t = type(module_result)
		if t == "table" or t == "string" then
			ps_utils.insert_in_spec(module_result)
		end
	else
		print("Failed to load " .. full_module_name)
		print(module_result)
	end
end

-- INFO: Make sure the specs are valid
ps_utils.validate_lazy_rock_specs()
