plugin("mini.indentscope"):for_cat("core"):defer():init(function()
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
		},
		callback = function()
			vim.b.miniindentscope_disable = true
		end,
	})
end)
plugin("todo-comments.nvim"):on_require("todo-comments"):defer():opts({
	highlight = {
		multiline = false,
	},
})
plugin("nvim-highlight-colors"):defer():opts({
	render = "virtual",
	virtual_symbol = "",
	virtual_symbol_position = "eow",
	virtual_symbol_prefix = " ",
	virtual_symbol_suffix = " ",
})
plugin("nvim-ts-autotag"):event({ "BufReadPre", "BufNewFile" })
plugin("mini.pairs"):defer():opts({
	modes = { insert = true, command = true, terminal = false },
})
plugin("mini.surround"):defer():opts({
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
plugin("mini.ai"):defer():config(function()
	local gen_spec = require("mini.ai").gen_spec
	require("mini.ai").setup({
		custom_textobjects = {
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
plugin("mini.move"):defer():opts({
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
plugin("nvim-surround"):defer()
plugin("comment.nvim"):defer():on_require("Comment"):opts(false)
plugin("tabout.nvim"):event("InsertCharPre"):on_require("tabout"):opts({
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
	:defer()
	:cmd({ "TSJSplit", "TSJJoin" })
	:keys({
		kmap("n", "S", kcmd("TSJSplit"), "Split"),
		kmap("n", "J", kcmd("TSJJoin"), "Join"),
	})
	:opts({
		use_default_keymaps = false,
	})
plugin("grug-far.nvim"):defer():on_require("grug-far"):opts({}):keys({
	kmap({ "n", "v" }, "<M-r>", function()
		require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })
	end, "replace current buffer"),
	kmap({ "n", "v" }, "<M-R>", function()
		require("grug-far").open()
	end, "replace global"),
})
