-- INFO: This file is loaded after the UI is opened.

-- Load base keybinds
require(vim.g.configs.keybinds_directory_name .. ".nvim")

local dap_utils = require("utils.dap")
dap_utils.load_vscode(nil)
vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = "*/.vscode/launch.json",
	callback = function()
		dap_utils.load_vscode(nil)
	end,
})
