plugin("folke/which-key.nvim"):event("VeryLazy"):priority(49):config(function()
	require("which-key").setup({
		triggers_blacklist = {
			i = { ";", ";" },
		},
		window = {
			border = "rounded",
		},
	})

	local wk = require("which-key")
	for _, group in ipairs(require("internal.keybinds").get_groups()) do
		wk.register({
			[group.prefix] = {
				name = group.description,
			},
		})
	end
end)
