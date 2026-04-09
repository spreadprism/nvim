plugin("yaml_nvim"):ft("yaml"):keymaps({
	k:map("n", "<localleader>fk", k:require("yaml_nvim").snacks(), "key"):ft("yaml"),
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
		k:group("yaml", "<localleader>", {
			k:map("n", "d", k:require("yaml-companion").add_crd_modelines(0, {}), "detect crds"),
			k:map("n", "c", k:require("yaml-companion").fetch_cluster_crd(0, {}), "fetch cluster crd"),
			k:group("find", "f", {
				k:map("n", "s", k:require("yaml-companion").open_ui_select(), "schemas"),
				k:map("n", "d", k:require("yaml-companion").open_datree_crd_select("modeline"), "datree crd"),
				k:map("n", "c", k:require("yaml-companion").open_cluster_crd_select("modeline"), "cluster crd"),
			}),
		}):ft("yaml"),
	})
