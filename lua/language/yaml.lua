formatter("yaml", "prettierd")
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
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = { "*.yaml", "*.yml", "*.json", "*.helm" },
	callback = function(args)
		kopts({ buffer = args.buf }, {
			kmap("n", "<leader>fk", kcmd("YAMLTelescope"), "key"),
		})
	end,
})
