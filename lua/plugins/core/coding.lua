plugin("mini.indentscope"):event_defer():init(function()
	vim.api.nvim_create_autocmd("FileType", {
		pattern = {
			"",
			"help",
			"leetcode.nvim",
			"alpha",
			"dashboard",
			"molten_output",
			"neo-tree",
			"Trouble",
			"trouble",
			"notify",
			"toggleterm",
			"lazyterm",
			"neotest-summary",
			"dbee",
			"noice",
		},
		callback = function()
			vim.b.miniindentscope_disable = true
		end,
	})
end)
plugin("todo-comments.nvim"):on_require("todo-comments"):event_defer():opts({
	highlight = {
		multiline = false,
		-- vimgrep regex, supporting the pattern TODO(name):
		pattern = [[.*<((KEYWORDS)%(\(.{-1,}\))?):]],
	},
	search = {
		-- ripgrep regex, supporting the pattern TODO(name):
		pattern = [[\b(KEYWORDS)(\(\w*\))*:]],
	},
})
plugin("nvim-highlight-colors"):event_defer():opts({
	render = "virtual",
	virtual_symbol = "",
	virtual_symbol_position = "eow",
	virtual_symbol_prefix = " ",
	virtual_symbol_suffix = " ",
})
plugin("easycolor")
	:keys({
		kmap("v", "<M-p>", "d<cmd>EasyColor<cr>", "open colorpicker"),
	})
	:dep_on("dressing.nvim")
plugin("nvim-ts-autotag"):event({ "BufReadPre", "BufNewFile" })
plugin("mini.pairs"):event_defer():opts({
	modes = { insert = true, command = true, terminal = false },
})
plugin("mini.surround"):event_defer():opts({
	mappings = {
		delete = "",
		find = "",
		find_left = "",
		highlight = "",
		replace = "",
		update_n_lines = "",
		suffix_last = "",
		suffix_next = "",
	},
})
plugin("mini.ai"):event_defer():config(function()
	local gen_spec = require("mini.ai").gen_spec
	require("mini.ai").setup({
		custom_textobjects = {
			a = gen_spec.treesitter({ a = "@attribute.outer", i = "@attribute.inner" }),
			f = gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
			c = gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
			i = gen_spec.treesitter({ a = "@conditional.outer", i = "@conditional.inner" }),
			g = gen_spec.treesitter({ a = "@comment.outer", i = "@comment.inner" }),
			l = gen_spec.treesitter({ a = "@loop.outer", i = "@loop.inner" }),
			p = gen_spec.treesitter({ a = "@parameter.outer", i = "@parameter.inner" }),
			r = gen_spec.treesitter({ a = "@return.outer", i = "@return.inner" }),
		},
	})
end)
plugin("mini.move"):event_defer():opts({
	mappings = {
		up = "<M-k>",
		down = "<M-j>",
		right = "",
		left = "",
		line_left = "",
		line_right = "",
		line_down = "<M-j>",
		line_up = "<M-k>",
	},
})
plugin("yanky.nvim")
	:event_defer()
	:keys({
		kmap("nx", "y", "<Plug>(YankyYank)", "yank"),
	})
	:opts({
		highlight = {
			timer = 100,
		},
		preserve_cursor_position = {
			enabled = true,
		},
	})
plugin("nvim-surround"):event_typing()
plugin("comment.nvim"):event_defer():on_require("Comment"):opts(false):config(function()
	local ft = require("Comment.ft")
	---@diagnostic disable-next-line: param-type-mismatch
	ft.set("helm", ft.get("yaml"))
end)
plugin("tabout.nvim"):event_typing():on_require("tabout"):opts({
	act_as_shift_tab = true,
	tabouts = {
		{ open = "'", close = "'" },
		{ open = '"', close = '"' },
		{ open = "`", close = "`" },
		{ open = "(", close = ")" },
		{ open = "[", close = "]" },
		{ open = "{", close = "}" },
		{ open = "<", close = ">" },
	},
})
plugin("treesj")
	:cmd({ "TSJSplit", "TSJJoin" })
	:keys({
		kmap("n", "gs", kcmd("TSJSplit"), "Split"),
		kmap("n", "gj", kcmd("TSJJoin"), "Join"),
	})
	:opts({
		use_default_keymaps = false,
	})
plugin("search-replace")
	:on_require("search-replace")
	:keys({
		kmap("v", "<M-r>", kcmd("SearchReplaceSingleBufferVisualSelection"), "replace"),
	})
	:event_defer()
plugin("grug-far.nvim"):on_require("grug-far"):keys({
	kmap("n", "<M-r>", function()
		require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })
	end, "replace current buffer"),
	kmap({ "n", "v" }, "<M-R>", function()
		require("grug-far").open()
	end, "replace global"),
})
plugin("neogen")
	:event_typing()
	:on_require("neogen")
	:opts({
		snippet_engine = "luasnip",
	})
	:keys({ kmap("n", "gca", klazy("neogen").generate(), "annotate") })

plugin("live-command")
	:event_defer()
	:opts({
		commands = {
			Norm = { cmd = "norm" },
		},
	})
	:setup(function()
		vim.cmd("cnoreabbrev norm Norm")
	end)
plugin("guess-indent"):event_defer()
plugin("undotree")
	:opts({
		window = {
			winblend = 0,
		},
	})
	:event_defer()
	:cmd("UndotreeToggle")
	:keys(kmap("n", "<M-u>", klazy("undotree").toggle(), "open undotree"))
plugin("quicker"):event_defer():keys(kmap("n", "<M-q>", klazy("quicker").toggle(), "toggle quick fix"))
