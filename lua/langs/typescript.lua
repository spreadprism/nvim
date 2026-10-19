local ft = { "typescript", "javascript", "typescriptreact", "javascriptreact" }

---@param kind string
local function source_action(kind)
	return function()
		vim.lsp.buf.code_action({
			context = { only = { kind }, diagnostics = {} },
			apply = true,
		})
	end
end

lsp("vtsls"):settings({
	typescript = {
		updateImportsOnFileMove = { enabled = "always" },
		inlayHints = {
			parameterNames = { enabled = "literals" },
			variableTypes = { enabled = true },
			propertyDeclarationTypes = { enabled = true },
			functionLikeReturnTypes = { enabled = true },
		},
	},
	javascript = {
		updateImportsOnFileMove = { enabled = "always" },
	},
})

k:map("n", "<localleader>o", source_action("source.organizeImports"), "organize imports"):ft(ft)
k:map("n", "<localleader>a", source_action("source.addMissingImports.ts"), "add missing imports"):ft(ft)
k:map("n", "<localleader>f", source_action("source.fixAll.ts"), "fix all"):ft(ft)

formatter(ft, "prettierd")
linter(ft, "eslint_d")
