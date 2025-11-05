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
kmap("nvo", "<M-o>", "%", "Move cursor to matching")
kmap("n", "<M-n>", function()
	require("which-key").show({ keys = "]" })
end, "next")
kmap("n", "<M-p>", function()
	require("which-key").show({ keys = "[" })
end, "previous")
-- INFO: Code manipulation
kmap("v", "<M-e>", function()
	vim.cmd(':call feedkeys(": Norm ")')
end, "Multi-edit")
kmap("v", "Y", '"+y', "Yank to clipboard")
kmap("n", "<M-J>", "Vyp", "Duplicate line down")
kmap("n", "<M-K>", "VyP", "Duplicate line up")
kmap("v", "<M-J>", "yp", "Duplicate line down")
kmap("v", "<M-K>", "yP", "Duplicate line up")
kmap("v", "<Tab>", ">gv", "Insert tab")
kmap("v", "<S-Tab>", "<gv", "Remove tab")
-- -- INFO: Tab management
kmap("n", "<M-Tab>", kcmd("tabnew"), "New tab")
kmap("n", "<M-!>", kcmd("tabn 1", true), "Go to tab 2")
kmap("n", "<M-@>", kcmd("tabn 2", true), "Go to tab 2")
kmap("n", "<M-#>", kcmd("tabn 3", true), "Go to tab 3")
kmap("n", "<M-$>", kcmd("tabn 4", true), "Go to tab 4")
kmap("n", "<M-%>", kcmd("tabn 5", true), "Go to tab 5")
kmap("n", "<M-^>", kcmd("tabn 6", true), "Go to tab 6")
kmap("n", "<M-&>", kcmd("tabn 7", true), "Go to tab 7")
kmap("n", "<M-*>", kcmd("tabn 8", true), "Go to tab 8")
kmap("n", "<M-(>", kcmd("tabn 9", true), "Go to tab 9")
