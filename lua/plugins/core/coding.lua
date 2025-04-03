plugin("mini.indentscope"):for_cat("core"):event_user():init(function()
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
plugin("todo-comments.nvim"):on_require("todo-comments"):event_user():opts({
	highlight = {
		multiline = false,
	},
})
plugin("nvim-highlight-colors"):event_user():opts({
	render = "virtual",
	virtual_symbol = "",
	virtual_symbol_position = "eow",
	virtual_symbol_prefix = " ",
	virtual_symbol_suffix = " ",
})
plugin("nvim-ts-autotag"):event({ "BufReadPre", "BufNewFile" })
plugin("mini.pairs"):event_user():opts({
	modes = { insert = true, command = true, terminal = false },
})
plugin("mini.surround"):event_user():opts({
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
plugin("mini.ai"):event_user():config(function()
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
plugin("mini.move"):event_user():opts({
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
plugin("nvim-surround"):event_user()
plugin("comment.nvim"):event_user():on_require("Comment"):opts(false)
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
plugin("grug-far.nvim"):event_user():on_require("grug-far"):opts({}):keys({
	kmap({ "n", "v" }, "<M-r>", function()
		require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })
	end, "replace current buffer"),
	kmap({ "n", "v" }, "<M-R>", function()
		require("grug-far").open()
	end, "replace global"),
})
