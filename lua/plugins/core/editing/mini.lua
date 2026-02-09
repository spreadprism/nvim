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
plugin("mini-ai"):on_require("mini.ai"):event("UIEnter"):opts(function()
	local spec_treesitter = require("mini.ai").gen_spec.treesitter
	return {
		mappings = {
			around_next = "",
			inside_next = "",
			inside_last = "",
			around_last = "",
		},
		custom_textobjects = {
			a = spec_treesitter({ a = "@assignment.outer", i = "@assignment.inner" }),
			f = spec_treesitter({ a = "@function.outer", i = "@function.inner" }),
			l = spec_treesitter({ a = "@loop.outer", i = "@loop.inner" }),
			i = spec_treesitter({ a = "@conditional.outer", i = "@conditional.inner" }),
			c = spec_treesitter({ a = "@class.outer", i = "@class.inner" }),
			r = spec_treesitter({ a = "@return.outer", i = "@return.inner" }),
			p = spec_treesitter({ a = "@parameter.outer", i = "@parameter.inner" }),
		},
	}
end)
