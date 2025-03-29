keymapLoad({
	keymap({ "i", "v", "s" }, ";;", "<Esc>", "Escape"),
	keymap("t", ";;", "<C-\\><C-n>", "Escape"),
	keymap("n", "<C-q>", keymapCmd("q"), "quit"),
	-- INFO: Code navigation
	keymap({ "n", "v", "x", "s", "o" }, "L", "g_", "Move cursor to last non-whitespace character"),
	keymap({ "n", "v", "x", "s", "o" }, "H", "^", "Move cursor to first non-whitespace character"),
	-- INFO: Code manipulation
	keymap("v", "Y", '"+y', "Yank to clipboard"),
	keymap("n", "<A-J>", "Vyp", "Duplicate line down"),
	keymap("n", "<A-K>", "VyP", "Duplicate line up"),
	keymap("v", "<A-J>", "yp", "Duplicate line down"),
	keymap("v", "<A-K>", "yP", "Duplicate line up"),
	keymap("n", "<A-o>", "o<ESC>k", "Insert line under"),
	keymap("n", "<A-O>", "O<ESC>k", "Insert line over"),
	keymap("v", "<Tab>", ">gv", "Insert tab"),
	keymap("v", "<S-Tab>", "<gv", "Remove tab"),
	-- INFO: Tab management
	keymap("n", "<A-t>", "<cmd>tabnew<cr>", "New tab"),
})
for i = 1, 9 do
	keymap("n", "<A-" .. i .. ">", keymapCmd("tabn " .. i, true), "Go to tab " .. i):load()
end
