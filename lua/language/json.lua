formatter("json", "prettier")
lsp("jsonls"):settings({
	json = {
		schemas = require("schemastore").json.schemas(),
		validate = { enable = true },
	},
})
