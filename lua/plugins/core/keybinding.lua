local wk = require("which-key")

-- keybindings initialization
wk.setup({
	win = {
		border = "rounded",
	},
	icons = {
		mappings = false,
	},
	defer = function(ctx)
		if vim.list_contains({ "d", "y", "v" }, ctx.operator) then
			return true
		end
		if vim.list_contains({ "<C-V>", "V" }, ctx.mode) then
			return true
		end
		return false
	end,
})

-- core keybindings
wk.add({
	kmap("iv", ";;", "<Esc>", "Escape"),
})
