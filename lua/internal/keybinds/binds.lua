local M = {}

M.register_keybind = function(mode, key, action, description, opts, force_api)
	force_api = force_api or false

	opts.desc = description

	if
		not pcall(function()
			if force_api then
				vim.api.nvim_set_keymap(mode, key, action, opts)
			else
				vim.keymap.set(mode, key, action, opts)
			end
		end)
	then
		vim.notify(
			"Failed to register keybind, invalid mode: " .. mode .. " => " .. key,
			vim.log.levels.WARNING,
			{ title = "Keybinds" }
		)
	end
end

return M
