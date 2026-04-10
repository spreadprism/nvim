plugin("vim-helm"):event("DeferredUIEnter"):opts(false):keymaps({
	k:map("n", "<localleader>v", function()
		-- First, try to get the chart root from helm_ls
		local clients = vim.lsp.get_clients({ bufnr = 0, name = "helm_ls" })
		if #clients > 0 then
			local client = clients[1]
			local root_dir = client.config.root_dir
			if root_dir then
				local values_file = root_dir .. "/values.yaml"
				if vim.fn.filereadable(values_file) == 1 then
					vim.cmd.edit(values_file)
					return
				end
			end
		end
		vim.notify("values.yaml not found", vim.log.levels.WARN)
	end, "open values file"):ft("helm"),
})
lsp("helm_ls"):settings({
	["helm-ls"] = {
		yamlls = {
			path = "yaml-language-server",
		},
	},
})
