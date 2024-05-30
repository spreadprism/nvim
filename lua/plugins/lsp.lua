local neoconf = plugin("folke/neoconf.nvim"):opts({ plugins = { lua_ls = { enabled = true } } })
plugin("neovim/nvim-lspconfig"):dependencies({ neoconf, "lewis6991/hover.nvim" }):config("configs.lsp")
plugin("linux-cultist/venv-selector.nvim")
	:branch("regexp")
	:lazy(false)
	:dependencies({
		"neovim/nvim-lspconfig",
		"nvim-telescope/telescope.nvim",
		"mfussenegger/nvim-dap",
		"mfussenegger/nvim-dap-python",
	})
	:opts({
		settings = {
			search = {
				anaconda_base = {
					command = "fd /python$ ~/miniconda3/ --full-path --color never -E /proc",
					type = "anaconda",
				},
				miniconda = {
					command = "fd bin/python$ ~/miniconda3/envs/ --full-path --color never -E /proc",
					type = "anaconda",
				},
			},
		},
	})
-- :config(function()
-- 	require("venv-selector").setup({
-- 		dap_enabled = true,
-- 		notify_user_on_activate = false,
-- 		anaconda_base_path = os.getenv("HOME") .. "/miniconda3",
-- 		anaconda_envs_path = os.getenv("HOME") .. "/miniconda3/envs",
-- 	})
-- end)
