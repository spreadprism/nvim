formatter("json", "prettierd")
lsp("jsonls"):settings({
	json = {
		schemas = require("schemastore").json.schemas(),
		validate = { enable = true },
	},
})
