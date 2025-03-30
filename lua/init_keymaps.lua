keymapLoad({
	keymap({ "i", "v", "s" }, ";;", "<Esc>", "Escape"),
	keymap("t", ";;", "<C-\\><C-n>", "Escape"),
	keymap("n", "<C-q>", function()
		if vim.tbl_contains(require("internal.dap_ui").dap_ui_ft, vim.bo.filetype) then
			require("internal.dap_ui").close()
		else
			vim.cmd("q")
		end
	end, "quit"),
	-- INFO: Code navigation
	keymap({ "n", "v", "x", "s", "o" }, "L", "g_", "Move cursor to last non-whitespace character"),
	keymap({ "n", "v", "x", "s", "o" }, "H", "^", "Move cursor to first non-whitespace character"),
	-- INFO: Code manipulation
	keymap("v", "Y", '"+y', "Yank to clipboard"),
	keymap("n", "<M-J>", "Vyp", "Duplicate line down"),
	keymap("n", "<M-K>", "VyP", "Duplicate line up"),
	keymap("v", "<M-J>", "yp", "Duplicate line down"),
	keymap("v", "<M-K>", "yP", "Duplicate line up"),
	keymap("n", "<M-o>", "o<ESC>k", "Insert line under"),
	keymap("n", "<M-O>", "O<ESC>k", "Insert line over"),
	keymap("v", "<Tab>", ">gv", "Insert tab"),
	keymap("v", "<S-Tab>", "<gv", "Remove tab"),
	-- INFO: Tab management
	keymap("n", "<M-Tab>", "<cmd>tabnew<cr>", "New tab"),
})
for i = 1, 9 do
	keymap("n", "<M-" .. i .. ">", keymapCmd("tabn " .. i, true), "Go to tab " .. i):load()
end
