plugin("yaml_nvim"):ft("yaml"):keymaps({
	k:map("n", "<leader>fk", k:require("yaml_nvim").snacks(), "find key"):ft("yaml"),
})

lsp("yamlls"):settings({
	yaml = {
		schemaStore = {
			enable = false,
			url = "",
		},
		schemas = require("schemastore").yaml.schemas(),
	},
})
