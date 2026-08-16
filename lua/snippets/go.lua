local ls = require("luasnip")

local snippet, inode, tnode, cnode, dnode, snode =
	ls.s, ls.insert_node, ls.text_node, ls.choice_node, ls.dynamic_node, ls.snippet_node

return {
	snippet("func", {
		tnode("func "),
		inode(1, "funcName"),
		tnode("("),
		inode(2),
		tnode(")"),
		-- return type: nothing / error / (T, error). The leading space lives in
		-- the non-empty choices so the empty one doesn't leave a double space.
		cnode(3, {
			tnode(""),
			tnode(" error"),
			snode(nil, {
				tnode(" ("),
				inode(1, "T"),
				tnode(", error)"),
			}),
		}),
		tnode({ " {", "\t" }),
		inode(0),
		tnode({ "", "}" }),
	}),
}
