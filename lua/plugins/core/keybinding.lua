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

for _, k in ipairs({
	-- CORE
	k:map("iv", ";;", "<Esc>", "Escape"),
	k:map("t", ";;", "<C-\\><C-n>", "Escape"),
	k:map("n", "<C-q>", k:cmd("q"), "Quit"),
	k:map("n", "<M-v>", "<C-v>", "raw char"),
	-- Navigation
	k:map("nvo", "L", "g_", "Move cursor to last non-whitespace character"),
	k:map("nvo", "H", "^", "Move cursor to first non-whitespace character"),
	k:map("n", "<C-w>t", "<C-w>v<C-w>T", "Open tab on current file"),
	k:map("nvo", "<M-o>", "%", "Move cursor to matching"),
	k:map("n", "<M-n>", k:lazy("which-key").show({ keys = "]" }), "next ..."),
	k:map("n", "<M-p>", k:lazy("which-key").show({ keys = "[" }), "previous ..."),
	-- Code manipulation
	k:map("v", "Y", '"+y', "Yank to clipboard"),
	k:map("n", "<M-J>", "Vyp", "Duplicate line down"),
	k:map("n", "<M-K>", "VyP", "Duplicate line up"),
	k:map("v", "<M-J>", "yp", "Duplicate line down"),
	k:map("v", "<M-K>", "yP", "Duplicate line up"),
	k:map("v", "<Tab>", ">gv", "Insert tab"),
	k:map("v", "<S-Tab>", "<gv", "Remove tab"),
	-- Tabs
	k:map("n", "<M-Tab>", k:cmd("tabnew"), "New tab"),
	k:map("n", "<M-!>", k:cmd("tabn 1", true), "Go to tab 2"),
	k:map("n", "<M-@>", k:cmd("tabn 2", true), "Go to tab 2"),
	k:map("n", "<M-#>", k:cmd("tabn 3", true), "Go to tab 3"),
	k:map("n", "<M-$>", k:cmd("tabn 4", true), "Go to tab 4"),
	k:map("n", "<M-%>", k:cmd("tabn 5", true), "Go to tab 5"),
	k:map("n", "<M-^>", k:cmd("tabn 6", true), "Go to tab 6"),
	k:map("n", "<M-&>", k:cmd("tabn 7", true), "Go to tab 7"),
	k:map("n", "<M-*>", k:cmd("tabn 8", true), "Go to tab 8"),
	k:map("n", "<M-(>", k:cmd("tabn 9", true), "Go to tab 9"),
}) do
	k:add()
end
