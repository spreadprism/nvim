plugin("yaml_nvim"):ft({ "yaml", "helm" }):keymaps({
	k:map("n", "<localleader>fk", k:require("yaml_nvim").snacks(), "key"):ft({ "yaml", "helm", "yaml.helm-values" }),
})
plugin("helm-ls"):event("DeferredUIEnter"):opts({
	conceal_templates = {
		enabled = false, -- this might change to false in the future
	},
	indent_hints = {
		only_for_current_line = false,
	},
})
plugin("yaml-companion")
	:event("DeferredUIEnter")
	:opts(false)
	:after(function()
		local cfg = require("yaml-companion").setup({
			modeline = {
				auto_add = {
					on_attach = true,
					on_save = true,
				},
				notify = false,
			},
			lspconfig = {
				settings = {
					yaml = {
						schemaStore = {
							enable = false,
							url = "",
						},
						schemas = require("schemastore").yaml.schemas(),
					},
				},
			},
		})
		vim.lsp.config("yamlls", cfg)
		vim.lsp.enable("yamlls")
	end)
	:keymaps({
		k:map("n", "<localleader>d", k:require("yaml-companion").add_crd_modelines(0, {}), "detect crds")
			:ft({ "yaml", "helm" }),
		k:map("n", "<localleader>c", k:require("yaml-companion").fetch_cluster_crd(0, {}), "fetch cluster crd")
			:ft({ "yaml", "helm" }),
		k:map("n", "<localleader>fs", k:require("yaml-companion").open_ui_select(), "schemas"):ft({ "yaml", "helm" }),
		k:map("n", "<localleader>fd", k:require("yaml-companion").open_datree_crd_select("modeline"), "datree crd")
			:ft({ "yaml", "helm" }),
		k:map("n", "<localleader>fc", k:require("yaml-companion").open_cluster_crd_select("modeline"), "cluster crd")
			:ft({ "yaml", "helm" }),
	})
