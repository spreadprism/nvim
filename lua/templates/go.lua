local ls = require("luasnip")
local snippet, inode, fnode, fmt = ls.snippet, ls.insert_node, ls.function_node, require("luasnip.extras.fmt").fmt

--- Package name for the file being templated: the directory it lives in.
local function package_name()
	return fnode(function()
		return vim.fs.basename(vim.fs.dirname(vim.api.nvim_buf_get_name(0)))
	end)
end

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
			fmt("package {}\n\n{}", { package_name(), inode(0) })
		),
	},
	{
		desc = "Go test file",
		detect = function(path, ctx)
			if not vim.fs.basename(path):match("_test%.go$") then
				return nil
			end
			return fs.find_up("go.mod", { path = ctx.dir }) and 100 or 50
		end,
		snippet = snippet(
			{ trig = "tmpl.go.test", hidden = true },
			fmt('package {}\n\nimport "testing"\n\n{}', { package_name(), inode(0) })
		),
	},
}
