plugin("mini-move"):on_require("mini.move"):event("DeferredUIEnter"):opts({
	mapings = {
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
plugin("mini-ai"):on_require("mini.ai"):event("DeferredUIEnter"):opts(false):after(function()
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
