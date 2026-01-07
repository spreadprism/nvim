plugin("which-key")
	:priority(100)
	:opts({
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
	:kmap("iv", ";;", "<Esc>", "Escape")
	:lazy(false)
