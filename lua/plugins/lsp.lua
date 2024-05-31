local neoconf = plugin("folke/neoconf.nvim"):opts({ plugins = { lua_ls = { enabled = true } } })
plugin("neovim/nvim-lspconfig"):dependencies({ neoconf, "lewis6991/hover.nvim" }):config("configs.lsp")
plugin("linux-cultist/venv-selector.nvim")
	:branch("regexp")
	:event("VeryLazy")
	:dependencies({
		"neovim/nvim-lspconfig",
		"nvim-telescope/telescope.nvim",
		"mfussenegger/nvim-dap",
		"mfussenegger/nvim-dap-python",
	})
	:opts({
		settings = {
			options = {
				on_telescope_result_callback = function(filename)
					filename = filename:gsub("/bin/python", "") ---@type string
					filename = vim.split(filename, "/")
					filename = filename[#filename]
					if filename == "miniconda3" then
						filename = "base"
					end
					return filename
				end,
			},
			search = {
				conda = {
					command = "fd bin/python$ ~/miniconda3/ --full-path --color never -E /proc -E /pkgs",
					type = "anaconda",
				},
				pipx = false,
			},
		},
	})
