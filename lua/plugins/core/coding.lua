plugin("mini.indentscope"):triggerUIEnter():for_cat("core"):before(function()
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

plugin("todo-comments.nvim"):on_require("todo-comments"):triggerBufferEnter():opts({
	highlight = {
		multiline = false,
	},
})
plugin("nvim-highlight-colors"):triggerBufferEnter():opts({
	render = "virtual",
	virtual_symbol = "",
	virtual_symbol_position = "eow",
	virtual_symbol_prefix = " ",
	virtual_symbol_suffix = " ",
})
plugin("nvim-ts-autotag"):event({ "BufReadPre", "BufNewFile" })
plugin("mini.pairs"):event({ "InsertEnter", "CmdlineEnter" }):opts({
	-- In which modes mappings from this `config` should be created
	modes = { insert = true, command = true, terminal = false },

	-- Global mappings. Each right hand side should be a pair information, a
	-- table with at least these fields (see more in |MiniPairs.map|):
	-- - <action> - one of 'open', 'close', 'closeopen'.
	-- - <pair> - two character string for pair to be used.
	-- By default pair is not inserted after `\`, quotes are not recognized by
	-- `<CR>`, `'` does not insert pair after a letter.
	-- Only parts of tables can be tweaked (others will use these defaults).
	mappings = {
		[")"] = { action = "close", pair = "()", neigh_pattern = "[^\\]." },
		["]"] = { action = "close", pair = "[]", neigh_pattern = "[^\\]." },
		["}"] = { action = "close", pair = "{}", neigh_pattern = "[^\\]." },
		["["] = {
			action = "open",
			pair = "[]",
			neigh_pattern = ".[%s%z%)}%]%,]",
			register = { cr = false },
		},
		["{"] = {
			action = "open",
			pair = "{}",
			neigh_pattern = ".[%s%z%)}%]%,]",
			register = { cr = false },
		},
		["("] = {
			action = "open",
			pair = "()",
			neigh_pattern = ".[%s%z%)%,]",
			register = { cr = false },
		},
		['"'] = {
			action = "closeopen",
			pair = '""',
			neigh_pattern = "[^%w\\][^%w]",
			register = { cr = false },
		},
		["'"] = {
			action = "closeopen",
			pair = "''",
			neigh_pattern = "[^%w\\][^%w]",
			register = { cr = false },
		},
		["`"] = {
			action = "closeopen",
			pair = "``",
			neigh_pattern = "[^%w\\][^%w]",
			register = { cr = false },
		},
	},
})
plugin("mini.surround"):triggerUIEnter():opts({
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
plugin("mini.ai"):triggerBufferEnter():after(function(_)
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
plugin("mini.move"):triggerUIEnter():opts({
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
plugin("nvim-surround"):triggerUIEnter()
plugin("comment.nvim"):triggerUIEnter():after(function(_)
	require("Comment").setup()
end)
