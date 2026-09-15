local ls = require("luasnip")
local snippet, inode, fmt = ls.snippet, ls.insert_node, require("luasnip.extras.fmt").fmt

---@type template.Entry[]
return {
	{
		desc = ".envrc",
		detect = function(path)
			return vim.fs.basename(path) == ".envrc" and 50 or nil
		end,
		snippet = snippet({ trig = "tmpl.envrc.generic", hidden = true }, fmt("use devenv{}", { inode(0) })),
	},
}
