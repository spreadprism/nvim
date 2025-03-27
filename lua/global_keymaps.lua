keymap:set({ "i", "v", "s" }, ";;", "<Esc>", "Escape")
keymap:set("t", ";;", "<C-\\><C-n>", "Escape")
keymap:set("n", "<C-q>", keymap:cmd("q"), "quit")

-- INFO: Code navigation
keymap:set({ "n", "v", "x", "s" }, "L", "g_", "Move cursor to last non-whitespace character")
keymap:set({ "n", "v", "x", "s" }, "H", "^", "Move cursor to first non-whitespace character")

-- INFO: Code manipulation
keymap:set("v", "Y", '"+y', "Yank to clipboard")
keymap:set("n", "<A-J>", "Vyp", "Duplicate line down")
keymap:set("n", "<A-K>", "VyP", "Duplicate line up")
keymap:set("v", "<A-J>", "yp", "Duplicate line down")
keymap:set("v", "<A-K>", "yP", "Duplicate line up")
keymap:set("n", "<A-o>", "o<ESC>k", "Insert line under")
keymap:set("n", "<A-O>", "O<ESC>k", "Insert line over")
keymap:set("v", "<Tab>", ">gv", "Insert tab")
keymap:set("v", "<S-Tab>", "<gv", "Remove tab")

-- INFO: Tab management
keymap:set("n", "<A-t>", "<cmd>tabnew<cr>", "New tab")

local function gototab(n)
	return function()
		---@diagnostic disable-next-line: param-type-mismatch
		pcall(vim.cmd, "tabn " .. n)
	end
end
for i = 1, 9 do
	keymap:set("n", "<A-" .. i .. ">", gototab(i), "Go to tab " .. i)
end
