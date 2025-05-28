formatter("yaml", "prettierd")
lsp("yamlls"):ft("yaml", "yaml.docker-compose", "yaml.gitlab", "helm"):settings({
	yaml = {
		schemaStore = {
			enable = false,
			url = "",
		},
		schemas = require("schemastore").yaml.schemas(),
	},
})
