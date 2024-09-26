lsp("ruff_lsp"):display(nil)
dap("debugpy"):initialize(false) --INFO: nvim-dap-python will take care of configuring
formatter("python", "ruff")
launch_configs("python", {
	{
		type = "python",
		request = "launch",
		name = "Launch file",
		program = "${file}",
		console = "integratedTerminal",
	},
})

local python_display = function(lsp_name)
	return function()
		local venv_name = require("venv-selector").venv()

		if venv_name ~= nil then
			venv_name = string.gsub(venv_name, ".*/pypoetry/virtualenvs/*", "")
			venv_name = string.gsub(venv_name, ".*/miniconda3/envs/", "")
			venv_name = string.gsub(venv_name, ".*/miniconda3", "base")
			venv_name = string.gsub(venv_name, ".*/.venv", "workspace")
		else
			venv_name = "sys"
		end
		return lsp_name .. "(" .. venv_name .. ")"
	end
end

local python_on_attach = function()
	keybind_group("<leader>l", "lsp"):register({
		keybind("n", "v", "<cmd>VenvSelect<cr>", "Select virtual environment"),
	})
end

lsp("pyright")
	:on_attach(python_on_attach)
	:cond(function()
		return vim.fn.executable("delance-langserver") == 0
	end)
	:display(python_display("pyright"))

lsp("pylance")
	:auto_install(false)
	:on_attach(python_on_attach)
	:cond(function()
		return vim.fn.executable("delance-langserver") == 1
	end)
	:display(python_display("pylance"))
	:register(function()
		local configs = require("lspconfig.configs")
		if not configs.pylance then
			configs.pylance = {
				default_config = {
					cmd = { "delance-langserver", "--stdio" },
					filetypes = { "python" },
					root_dir = require("lspconfig.util").root_pattern(
						"pyproject.toml",
						"setup.py",
						"setup.cfg",
						"requirements.txt",
						"Pipfile",
						"pyrightconfig.json",
						".git"
					),
					single_file_support = true,
					settings = {
						python = {
							analysis = {
								include = {
									vim.fn.stdpath("config") .. "/python",
								},
								packageIndexDepths = {
									{
										name = "",
										depth = 2,
										includeAllSymbols = true,
									},
								},
								autoSearchPaths = true,
								useLibraryCodeForTypes = true,
								diagnosticMode = "openFilesOnly",
							},
						},
					},
				},
			}
		end
	end)

plugin("mfussenegger/nvim-dap-python")
	:ft("python")
	:dependencies({ "mfussenegger/nvim-dap", "rcarriga/nvim-dap-ui" })
	:config(function()
		require("dap-python").setup("~/miniconda3/bin/python")
		require("internal.dap").refresh_configurations("python") -- INFO: Removes the default configs
	end)

plugin("linux-cultist/venv-selector.nvim")
	:branch("regexp")
	:ft("python")
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
