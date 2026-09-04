plugin("which-key")
	:lazydev({ words = { "wk" } })
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
		plugins = {
			registers = false,
		},
	})
	:keymaps({
		k:map("iv", ";;", "<Esc>", "Escape"),
		k:map("t", ";;", "<C-\\><C-n>", "Escape"),
		k:map("n", "<C-q>", k:cmd("q"), "Quit"),
		k:map("n", "<M-v>", "<C-v>", "raw char"),
		-- Navigation
		k:map("nvo", "L", "g_", "Move cursor to last non-whitespace character"),
		k:map("nvo", "H", "^", "Move cursor to first non-whitespace character"),
		k:map("n", "<C-w>t", "<C-w>v<C-w>T", "Open tab on current file"),
		k:map("nvo", "<M-o>", "%", "Move cursor to matching"),
		k:map("n", "<M-/>", function()
			if vim.v.hlsearch == 1 then
				vim.cmd("noh")
			end
		end, "Clear search highlight if active"),
		-- Code manipulation
		k:map("v", "Y", '"+y', "Yank to clipboard"),
		k:map("n", "<M-J>", "Vyp", "Duplicate line down"),
		k:map("n", "<M-K>", "VyP", "Duplicate line up"),
		k:map("v", "<M-J>", "yp", "Duplicate line down"),
		k:map("v", "<M-K>", "yP", "Duplicate line up"),
		k:map("v", "<Tab>", ">gv", "Insert tab"),
		k:map("v", "<S-Tab>", "<gv", "Remove tab"),
		-- Multicursor
		k:map("n", "<Esc>", function()
			vim.api.nvim_buf_clear_namespace(0, vim.api.nvim_create_namespace("nvim.multicursor"), 0, -1)
		end, "Clear multicursors"),
		k:map("n", "<M-n>", function()
			local ns = vim.api.nvim_create_namespace("nvim.multicursor")
			local marks = vim.api.nvim_buf_get_extmarks(0, ns, 0, -1)
			if #marks ~= 0 then
				vim.api.nvim_feedkeys("Qn", "n", false) -- place a cursor and jump to the next match
				return
			end
			vim.api.nvim_feedkeys("wbQ", "n", false) -- move to the beginning of the word and place a cursor
			vim.fn.setreg("/", "\\V" .. vim.fn.expand("<cword>")) -- set search pattern to the current word
			vim.api.nvim_feedkeys("n", "n", false)
		end, "Place cursor and search for word under the cursor"),
		-- Tabs
		k:map("n", "<M-Tab>", k:cmd("tab split"), "New tab with current buffer"),
		k:map("n", "<M-!>", k:cmd("tabn 1", true), "Go to tab 2"),
		k:map("n", "<M-@>", k:cmd("tabn 2", true), "Go to tab 2"),
		k:map("n", "<M-#>", k:cmd("tabn 3", true), "Go to tab 3"),
		k:map("n", "<M-$>", k:cmd("tabn 4", true), "Go to tab 4"),
		k:map("n", "<M-%>", k:cmd("tabn 5", true), "Go to tab 5"),
		k:map("n", "<M-^>", k:cmd("tabn 6", true), "Go to tab 6"),
		k:map("n", "<M-&>", k:cmd("tabn 7", true), "Go to tab 7"),
		k:map("n", "<M-*>", k:cmd("tabn 8", true), "Go to tab 8"),
		k:map("n", "<M-(>", k:cmd("tabn 9", true), "Go to tab 9"),
		-- Dev
		k:group("dev", "<leader>="),
		k:map("n", "<leader>=s", ":source %<CR>", "source current file"):ft("lua"),
	})
	:priority(1000)
	:lazy(false)
