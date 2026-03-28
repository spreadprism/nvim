local ls = require("luasnip")

local s, i, t, f, r, fmt =
	ls.s,
	ls.insert_node,
	ls.text_node,
	ls.function_node,
	require("luasnip.extras").rep,
	require("luasnip.extras.fmt").fmt

return {
	s("schema", fmt("# yaml-language-server: $schema={}", { i(0) })),
}
