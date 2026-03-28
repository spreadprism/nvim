local ls = require("luasnip")

local s, i, t, f, r, fmt =
	ls.s,
	ls.insert_node,
	ls.text_node,
	ls.function_node,
	require("luasnip.extras").rep,
	require("luasnip.extras.fmt").fmt

return {
	s("blk", fmt("```{}\n{}\n```", { i(1), i(0) })),
	s("link", fmt("[{}]({})", { i(1), i(0) })),
	s("image", fmt("![{}]({})", { i(1), i(0) })),
}
