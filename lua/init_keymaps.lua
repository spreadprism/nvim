---@diagnostic disable-next-line: missing-fields
require("which-key").setup({
	win = {
		border = "rounded",
	},
	icons = {
		mappings = false,
	},
})
kmap("ivs", ";;", "<Esc>", "Escape")
kmap("t", ";;", "<C-\\><C-n>", "Escape")
kmap("n", "<C-q>", kcmd("q"), "quit")
-- -- INFO: Code navigation
kmap("nvxso", "L", "g_", "Move cursor to last non-whitespace character")
kmap("nvxso", "H", "^", "Move cursor to first non-whitespace character")
-- -- INFO: Code manipulation
kmap("v", "Y", '"+y', "Yank to clipboard")
kmap("n", "<M-J>", "Vyp", "Duplicate line down")
kmap("n", "<M-K>", "VyP", "Duplicate line up")
kmap("v", "<M-J>", "yp", "Duplicate line down")
kmap("v", "<M-K>", "yP", "Duplicate line up")
kmap("n", "<M-o>", "o<ESC>k", "Insert line under")
kmap("n", "<M-O>", "O<ESC>k", "Insert line over")
kmap("v", "<Tab>", ">gv", "Insert tab")
kmap("v", "<S-Tab>", "<gv", "Remove tab")
-- -- INFO: Tab management
kmap("n", "<M-Tab>", kcmd("tabnew"), "New tab")
for i = 1, 9 do
	kmap("n", "<M-" .. i .. ">", kcmd("tabn " .. i, true), "Go to tab " .. i)
end
