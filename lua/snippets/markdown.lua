local ls = require("luasnip")

local snippet, inode, fmt = ls.s, ls.insert_node, require("luasnip.extras.fmt").fmt

return {
	snippet("blk", fmt("```{}\n{}\n```", { inode(1), inode(0) })),
}
