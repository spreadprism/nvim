local dap = require("dap")
local dap_utils = require("utils.dap")

dap_utils.init_adapters()
dap_utils.init_configurations()

-- INFO: Force vscode launch.json configs to be before global configs
local global = dap.providers.configs["dap.global"]
local launchjson = dap.providers.configs["dap.launch.json"]

dap.providers.configs["dap.global"] = nil
dap.providers.configs["dap.launch.json"] = nil

dap.providers.configs["dap.custom"] = function(bufnr)
	local configs = {}
	configs = vim.list_extend(configs, launchjson())
	configs = vim.list_extend(configs, global(bufnr))
	return configs
end
