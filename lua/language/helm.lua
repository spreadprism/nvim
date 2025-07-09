if not nixCats("language.helm") then
	return
end
lsp("helm_ls"):settings({
	["helm-ls"] = {
		path = "yaml-language-server",
		yamlls = {
			enabled = false,
		},
	},
})
