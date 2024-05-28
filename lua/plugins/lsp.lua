local neoconf = plugin("folke/neoconf.nvim"):opts({ plugins = { lua_ls = { enabled = true } } })
plugin("neovim/nvim-lspconfig"):dependencies({ neoconf, "lewis6991/hover.nvim" }):config("configs.lsp")
plugin("linux-cultist/venv-selector.nvim")
	:ft({ "python" })
	:cmd("VenvSelect")
	:dependencies({ "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim", "mfussenegger/nvim-dap-python" })
	:opts({
		dap_enabled = true,
		notify_user_on_activate = false,
		anaconda_base_path = os.getenv("HOME") .. "/miniconda3",
		anaconda_envs_path = os.getenv("HOME") .. "/miniconda3/envs",
	})
