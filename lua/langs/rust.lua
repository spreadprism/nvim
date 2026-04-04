plugin("rustaceanvim")
	:lazy(false)
	:priority(49)
	:opts(false)
	:before(function()
		---@type rustaceanvim.Opts
		vim.g.rustaceanvim = {
			tools = {
				test_executor = "neotest",
				enable_clippy = false,
			},
			dap = {
				adapter = false,
				configuration = false,
				autoload_configurations = false,
			},
		}
	end)
	:lazydev({
		words = { "rustaceanvim" },
	})
dap.adapter({ "rust", "codelldb" }, {
	type = "server",
	port = "13000",
	executable = {
		command = "codelldb",
		args = { "--port", "13000" },
	},
})
linter("rust", "clippy")
formatter("rust", "rustfmt")
