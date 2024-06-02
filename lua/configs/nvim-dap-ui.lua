local prefered_output = {
	go = 1,
	cs = 1,
	typescriptreact = 1,
	typescript = 1,
	javascript = 1,
}

require("dap").listeners.after.event_initialized["dapui_config"] = function()
	local file_type = vim.bo.filetype

	local ui = prefered_output[file_type] or 2
	require("dapui").open(ui)
end

require("dapui").setup({
	floating = {
		border = "rounded",
	},
	layouts = {
		{
			elements = {
				{
					id = "repl",
					size = 0.5,
				},
			},
			position = "bottom",
			size = 0.3,
		},
		{
			elements = {
				{
					id = "console",
					size = 1,
				},
			},
			position = "bottom",
			size = 0.3,
		},
	},
})
