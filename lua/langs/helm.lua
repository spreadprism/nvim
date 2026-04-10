plugin("vim-helm"):event("DeferredUIEnter"):opts(false)
lsp("helm_ls"):settings({
	["helm-ls"] = {
		yamlls = {
			path = "yaml-language-server",
		},
	},
})
