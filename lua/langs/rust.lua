linter("rust", "clippy")
formatter("rust", "rustfmt")
-- setups lsp, dap, neotest
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
				adapter = function()
					---@type dap.Adapter
					---@diagnostic disable-next-line: return-type-mismatch
					return {
						type = "server",
						host = "127.0.0.1",
						port = "${port}",
						executable = {
							command = "codelldb",
							args = { "--port", "${port}" },
						},
						enrich_config = function(config, on_config)
							config.console = "internalConsole"
							on_config(config)
						end,
					}
				end,
				autoload_configurations = false,
			},
		}
	end)
	:lazydev({
		words = { "rustaceanvim" },
	})
