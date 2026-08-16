local ls = require("luasnip")
local snippet, inode, fnode, fmt = ls.snippet, ls.insert_node, ls.function_node, require("luasnip.extras.fmt").fmt

---@type template.Entry[]
return {
	{
		desc = "Go main entrypoint",
		detect = function(path, ctx)
			if vim.fs.basename(path) ~= "main.go" then
				return nil
			end
			return fs.find_up("go.mod", { path = ctx.dir }) and 100 or 50
		end,
		snippet = snippet(
			{ trig = "tmpl.go.main", hidden = true },
			fmt("package main\n\nfunc main() {{\n\t{}\n}}", { inode(0) })
		),
	},
	{
		desc = "Go file",
		detect = function(_, ctx)
			return ctx.ft == "go" and 10 or nil
		end,
		snippet = snippet(
			{ trig = "tmpl.go.generic", hidden = true },
			fmt("package {}\n\n{}", {
				fnode(function()
					return vim.fs.basename(vim.fs.dirname(vim.api.nvim_buf_get_name(0)))
				end),
				inode(0),
			})
		),
	},
}
