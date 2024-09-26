lsp("gopls")
formatter("go", "gofmt"):install(false)
launch_configs("go", {
	{
		name = "Launch current file",
		type = "go",
		request = "launch",
		program = "${file}",
	},
})

plugin("leoluz/nvim-dap-go")
	:ft("go")
	:dependencies({ "mfussenegger/nvim-dap", "rcarriga/nvim-dap-ui" })
	:config(function()
		require("dap-go"):setup({
			experimental = {
				test_table = true,
			},
		})
		require("internal.dap").refresh_configurations("go") -- INFO: Removes the default configs
	end)
