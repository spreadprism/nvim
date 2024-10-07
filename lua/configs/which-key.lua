plugin("folke/which-key.nvim"):event("VeryLazy"):priority(49):config(function()
	require("which-key").setup({
		win = {
			border = "rounded",
		},
		icons = {
			mappings = false,
		},
	})

	local wk = require("which-key")
	for _, group in ipairs(require("internal.keybinds").get_groups()) do
		wk.add({
			group.prefix,
			group = group.description,
		})
	end
end)
