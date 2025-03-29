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
	s("h1", fmt("# {}", { i(0) })),
	s("h2", fmt("## {}", { i(0) })),
	s("h3", fmt("### {}", { i(0) })),
	s("h4", fmt("#### {}", { i(0) })),
}
