-- INFO: This file is loaded after the UI is opened.

-- Load base keybinds
require(vim.g.configs.keybinds_directory_name .. ".nvim")

require("utils.dap").load_vscode(nil)
vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = "*/.vscode/launch.json",
	callback = function()
		require("utils.dap").load_vscode(nil)
	end,
})
