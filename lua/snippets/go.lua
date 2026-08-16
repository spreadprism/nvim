local ls = require("luasnip")

local snippet, inode, tnode, cnode, fnode, snode =
	ls.s, ls.insert_node, ls.text_node, ls.choice_node, ls.function_node, ls.snippet_node

--- Zero value for a Go type.
---@param ty string
---@return string
local function zero_value(ty)
	ty = vim.trim(ty)
	if
		ty == ""
		or ty == "error"
		or ty == "any"
		or ty == "chan"
		or ty:match("^interface%s*{")
		or ty:match("^%*") -- pointer
		or ty:match("^%[%]") -- slice
		or ty:match("^map%[")
		or ty:match("^chan%s")
		or ty:match("^func%s*%(")
	then
		return "nil"
	end
	if ty == "string" then
		return '""'
	end
	if ty == "bool" then
		return "false"
	end
	if
		ty == "byte"
		or ty == "rune"
		or ty == "uintptr"
		or ty:match("^u?int%d*$")
		or ty:match("^float%d+$")
		or ty:match("^complex%d+$")
	then
		return "0"
	end
	-- named type, optionally package-qualified: assume a struct
	if ty:match("^[%w_]+$") or ty:match("^[%w_]+%.[%w_]+$") then
		return ty .. "{}"
	end
	return "nil"
end

--- Return types of the function/method/closure enclosing the cursor.
---@return string[]
local function enclosing_results()
	local got, node = pcall(vim.treesitter.get_node)
	if not got or not node then
		return {}
	end

	while node do
		local t = node:type()
		if t == "function_declaration" or t == "method_declaration" or t == "func_literal" then
			break
		end
		node = node:parent()
	end
	if not node then
		return {}
	end

	local result = node:field("result")[1]
	if not result then
		return {}
	end

	local types = {}
	if result:type() == "parameter_list" then
		for child in result:iter_children() do
			if child:type() == "parameter_declaration" then
				local ty = child:field("type")[1]
				if ty then
					-- `(a, b int)` binds one type to several names
					local names = child:field("name")
					local count = #names > 0 and #names or 1
					for _ = 1, count do
						table.insert(types, vim.treesitter.get_node_text(ty, 0))
					end
				end
			end
		end
	else
		-- single unnamed return, e.g. `func f() error`
		table.insert(types, vim.treesitter.get_node_text(result, 0))
	end
	return types
end

--- Zero values for every return of the enclosing function except a trailing
--- `error`, ready to prefix `err`. "" for `func() error`, `"", 0, ` for
--- `func() (string, int, error)`.
---@return string
local function default_returns()
	local types = enclosing_results()
	if #types > 0 and vim.trim(types[#types]) == "error" then
		table.remove(types)
	end
	if #types == 0 then
		return ""
	end

	local out = {}
	for _, ty in ipairs(types) do
		table.insert(out, zero_value(ty))
	end
	return table.concat(out, ", ") .. ", "
end

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
	snippet("type", {
		tnode("type "),
		inode(1, "Name"),
		tnode(" "),
		cnode(2, {
			snode(nil, {
				tnode({ "struct {", "\t" }),
				inode(1),
				tnode({ "", "}" }),
			}),
			snode(nil, {
				tnode({ "interface {", "\t" }),
				inode(1),
				tnode({ "", "}" }),
			}),
			-- alias: shares the original's identity and method set
			snode(nil, {
				tnode("= "),
				inode(1, "otherType"),
			}),
			-- defined type: new identity, does NOT inherit methods
			snode(nil, {
				inode(1, "otherType"),
			}),
		}),
		inode(0),
	}),
	snippet("tfunc", {
		tnode("func Test"),
		inode(1, "Name"),
		tnode({ "(t *testing.T) {", "\t" }),
		inode(0),
		tnode({ "", "}" }),
	}),
	snippet("iferr", {
		tnode("if "),
		cnode(1, {
			tnode(""),
			snode(nil, {
				inode(1, "args"),
				tnode(", err := "),
				inode(2, "fn"),
				tnode("("),
				inode(3),
				tnode("); "),
			}),
		}),
		tnode({ "err != nil {", "\treturn " }),
		-- filled from the enclosing function's return types at expansion time
		fnode(default_returns, {}),
		cnode(2, {
			tnode("err"),
			snode(nil, {
				tnode('errors.Wrap(err, "'),
				inode(1),
				tnode('")'),
			}),
		}),
		tnode({ "", "}" }),
		inode(0),
	}),
}
