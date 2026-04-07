lsp("tofu_ls"):opts({
	on_init = function(client, _)
		client.server_capabilities.semanticTokensProvider = nil
	end,
})
linter("tf", "tflint")
formatter("tf", "tofu_fmt")
formatter("hcl", "terragrunt_hclfmt")
