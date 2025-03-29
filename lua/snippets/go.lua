local ls = require("luasnip")

local s, i, t, f, r, fmt =
	ls.s,
	ls.insert_node,
	ls.text_node,
	ls.function_node,
	require("luasnip.extras").rep,
	require("luasnip.extras.fmt").fmt

return {
	s("if", fmt("if {} {{\n  {}\n}}", { i(1), i(0) })),
	s("tfunc", fmt("func Test{}(t *testing.T) {{\n  {}\n}}", { i(1), i(0)})),
	s("struct", fmt("type {} struct {{\n  {}\n}}", { i(1), i(0) })),
	s("interface", fmt("type {} interface {{\n  {}\n}}", { i(1), i(0) })),
}
