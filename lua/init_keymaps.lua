---@diagnostic disable-next-line: missing-fields
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
		return vim.list_contains({ "<C-V>", "V" }, ctx.mode)
	end,
})
kmap("iv", ";;", "<Esc>", "Escape")
kmap("t", ";;", "<C-\\><C-n>", "Escape")
kmap("n", "<C-q>", kcmd("q"), "quit")
kmap("i", "<M-v>", "<C-v>", "raw char")
-- -- INFO: Code navigation
kmap("nvo", "L", "g_", "Move cursor to last non-whitespace character")
kmap("nvo", "H", "^", "Move cursor to first non-whitespace character")
kmap("n", "<M-n>", function()
	require("which-key").show({ keys = "]" })
end, "next")
kmap("n", "<M-p>", function()
	require("which-key").show({ keys = "[" })
end, "previous")
-- INFO: Code manipulation
kmap("v", "Y", '"+y', "Yank to clipboard")
kmap("n", "<M-J>", "Vyp", "Duplicate line down")
kmap("n", "<M-K>", "VyP", "Duplicate line up")
kmap("v", "<M-J>", "yp", "Duplicate line down")
kmap("v", "<M-K>", "yP", "Duplicate line up")
kmap("v", "<Tab>", ">gv", "Insert tab")
kmap("v", "<S-Tab>", "<gv", "Remove tab")
-- -- INFO: Tab management
kmap("n", "<M-Tab>", kcmd("tabnew"), "New tab")
for i = 1, 9 do
	kmap("n", "<M-" .. i .. ">", kcmd("tabn " .. i, true), "Go to tab " .. i)
end
