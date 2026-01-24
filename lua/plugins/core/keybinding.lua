require("which-key").setup({
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
	plugins = {
		registers = false,
	},
})

k:map("iv", ";;", "<Esc>", "Escape"):add()
