formatter({ "yaml", "helm" }, "prettierd")
lsp("yamlls"):ft("yaml", "yaml.docker-compose", "yaml.gitlab"):settings({
	yaml = {
		schemaStore = {
			enable = false,
			url = "",
		},
		schemas = require("schemastore").yaml.schemas(),
	},
})

plugin("yaml"):ft("yaml", "json", "helm"):on_require("yaml_nvim"):opts({
	ft = { "yaml", "helm" },
})
