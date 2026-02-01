local M = {}

M.setup = {
	plugins = {},
	spec_field = "opts",
	set_lazy = false,
	add = function(plugin)
		M.setup.plugins[plugin.name] = plugin
	end,
	modify = function(plugin)
		if plugin.opts == nil then
			plugin.opts = {}
		end
		return plugin
	end,
	after = function(name)
		local plugin = M.setup.plugins[name]

		local opts = plugin.opts

		if opts == false then
			return
		end

		if type(opts) == "function" then
			opts = opts(plugin)
		end

		local ok, module = pcall(require, plugin.on_require)
		if not ok then
			print("Error loading plugin module: " .. name .. " (cause=" .. module .. ")")
			return
		end

		if module.setup then
			module.setup(opts)
		else
			if opts ~= {} then
				print("Warning: Plugin " .. name .. " does not have a setup function to apply opts.")
			end
		end
	end,
}

M.keymaps = {
	plugins = {},
	spec_field = "keymaps",
	set_lazy = true,
	add = function(plugin)
		M.keymaps.plugins[plugin.name] = plugin
	end,
	modify = function(plugin)
		if plugin.keymaps == nil then
			return plugin
		end
		vim.api.nvim_create_autocmd("User", {
			pattern = {
				"DeferredUIEnter",
			},
			callback = function(_)
				require("internal.keymaps"):add(plugin.keymaps)
			end,
		})

		return plugin
	end,
}

return M
