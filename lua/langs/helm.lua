plugin("vim-helm"):event("DeferredUIEnter"):opts(false)
lsp("helm_ls"):settings({
	["helm-ls"] = {
		yamlls = {
			config = {
				schemas = require("schemastore").yaml.schemas(),
			},
		},
	},
})
