-- Exit keybinds
keybind({ "i", "v" }, ";;", "<Esc>", "Escape iv"):register()
keybind("t", ";;", "<C-\\><C-n>", "Escape term"):register()
keybind("n", "<C-s>", "<cmd>w<CR>", "Save"):register()
keybind("n", "<C-q>", "<cmd>q<CR>", "Quit"):register()

-- INFO: Open stuff
keybind_group("<leader>o", "Open"):register({
	keybind("n", "l", "<cmd>Lazy<cr>", "Open Lazy"),
	keybind("n", "m", "<cmd>Mason<cr>", "Open Mason"),
	keybind("n", "d", "<cmd>Dashboard<cr>", "Open dashboard"),
})

-- INFO: Code Navigation
keybind({ "n", "v", "x", "s" }, "L", "g_", "Move cursor to last non-whitespace character"):register()
keybind({ "n", "v", "x", "s" }, "H", "^", "Move cursor to last non-whitespace character"):register()

-- INFO: Code manipulation
keybind("v", "Y", '"+y', "Yank to clipboard"):register()
keybind("n", "<A-J>", "Vyp", "Duplicate line down"):register()
keybind("n", "<A-K>", "VyP", "Duplicate line up"):register()
keybind("v", "<A-J>", "yp", "Duplicate line down"):register()
keybind("v", "<A-K>", "yP", "Duplicate line up"):register()
keybind("n", "<A-o>", "o<ESC>k", "Insert line under"):register()
keybind("n", "<A-O>", "O<ESC>k", "Insert line over"):register()
keybind("v", "<Tab>", ">gv", "Insert table"):register()
keybind("v", "<S-Tab>", "<gv", "Remove tab"):register()

keybind("i", "<S-Tab>", "<C-h>", "Remove tab"):register()

---@param n integer
local gototab = function(n)
	return function()
		pcall(vim.cmd, "tabn " .. n)
	end
end
keybind("n", "<A-t>", "<cmd>tabnew<cr>", "New tab"):register()
-- Go to tab #1
keybind("n", "<A-1>", gototab(1), "Go to tab 1"):register()
keybind("n", "<A-2>", gototab(2), "Go to tab 2"):register()
keybind("n", "<A-3>", gototab(3), "Go to tab 3"):register()
keybind("n", "<A-4>", gototab(4), "Go to tab 4"):register()
keybind("n", "<A-5>", gototab(5), "Go to tab 5"):register()
keybind("n", "<A-6>", gototab(6), "Go to tab 6"):register()
keybind("n", "<A-7>", gototab(7), "Go to tab 7"):register()
keybind("n", "<A-8>", gototab(8), "Go to tab 8"):register()
keybind("n", "<A-9>", gototab(9), "Go to tab 9"):register()
