local modules_utils = require("internal.module")
local fs = require("internal.fs")
local M = {}

---@param url string
M.generate_possible_names = function(url)
	local split = vim.split(url, "/")
	local name = split[#split]
	local possible_names = {
		[name] = true,
		[name:gsub(".nvim", "")] = true,
		[name:gsub("%-nvim", "")] = true,
		[name:gsub("nvim%-", "")] = true,
	}
	local name_lower = name:lower()
	if name_lower ~= name then
		possible_names = vim.list_extend(possible_names, {
			[name_lower] = true,
			[name_lower:gsub(".nvim", "")] = true,
			[name_lower:gsub("%-nvim", "")] = true,
			[name_lower:gsub("nvim%-", "")] = true,
		})
	end
	return possible_names
end

---@param plugin Plugin
local convert_config_to_lazy_spec = function(plugin)
	-- TODO:
	-- if plugin.specs.config == nil then
	-- 	local config_modules = modules_utils.list_submodules("configs", "*", true)
	-- 	print(config_modules)
	-- 	print(plugin.possible_names)
	-- 	for _, name in ipairs(plugin.possible_names) do
	-- 		if vim.list_contains(config_modules, "configs." .. name) then
	-- 			plugin.specs.config = function()
	-- 				local ok, err = pcall(require, "configs." .. name)
	-- 				if not ok then
	-- 					vim.notify(err, vim.log.levels.ERROR, { title = "LazyRockSpecs" })
	-- 				end
	-- 			end
	-- 			break
	-- 		end
	-- 	end
	-- elseif type(plugin.specs.config) == "string" then
	-- 	local config_name = plugin.specs.config
	-- 	plugin.specs.config = function()
	-- 		if plugin.specs.opts ~= nil then
	-- 			---@diagnostic disable-next-line: param-type-mismatch
	-- 			require(config_name).setup(plugin.specs.opts)
	-- 		else
	-- 			---@diagnostic disable-next-line: param-type-mismatch
	-- 			require(config_name).setup()
	-- 		end
	-- 	end
	-- end
end

---@param plugin Plugin
local convert_keys_to_lazy_spec = function(plugin)
	if plugin.specs.keys == nil then
		local keybind_modules = modules_utils.list_submodules("keybinds", "*", true)
		for name, _ in pairs(plugin.possible_names) do
			if vim.list_contains(keybind_modules, "keybinds." .. name) then
				plugin.specs.keys = function()
					local ok, err = pcall(require, name)
					if not ok then
						vim.notify(err, vim.log.levels.ERROR, { title = "LazyRockSpecs" })
					end
				end
				break
			end
		end
	end
end

M.plugin_to_lazy_spec = function(plugin)
	convert_config_to_lazy_spec(plugin)
	convert_keys_to_lazy_spec(plugin)
	return plugin.specs
end

M.load_all_configs = function()
	local specs = require("internal.lazy_specs.specs")
	local modules = modules_utils.list_submodules("configs", "*", true)

	for _, module in ipairs(modules or {}) do
		local ok, module_result = pcall(require, module)
		if ok then
			if type(module_result) == "function" then
				module_result = module_result()
			end
			local t = type(module_result)
			if t == "table" or t == "string" then
				specs.insert(module_result)
			end
		else
			print("Failed to load " .. module)
			print(module_result)
		end
	end
end

return M
