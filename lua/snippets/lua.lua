local ls = require("luasnip")

local snippet, inode, fnode, fmt = ls.s, ls.insert_node, ls.function_node, require("luasnip.extras.fmt").fmt

return {
	snippet(
		"require",
		fmt('local {} = require("{}")', {
			-- last dot-separated segment of the module path:
			-- foo.bar.thing.is.name -> name
			fnode(function(args)
				return (args[1][1] or ""):match("[^.]+$") or ""
			end, { 1 }),
			inode(1),
		})
	),
}
