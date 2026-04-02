formatter("json", "prettierd")
linter("json")
lsp("jsonls"):settings({
	json = {
		schemas = require("schemastore").json.schemas(),
		validate = { enable = false },
	},
})
