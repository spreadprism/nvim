formatter("yaml", "prettierd")
lsp("yamlls"):settings({
	yaml = {
		schemaStore = {
			enable = false,
			url = "",
		},
		schemas = require("schemastore").yaml.schemas(),
	},
})
