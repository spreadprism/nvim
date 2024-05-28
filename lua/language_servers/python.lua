lsp("ruff_lsp"):display(nil)
lsp("pyright")
	:on_attach(function()
		keybind_group("<leader>l", "lsp"):register({
			keybind("n", "v", "<cmd>VenvSelect<cr>", "Select virtual environment"),
		})
	end)
	:cond(function()
		return vim.fn.executable("delance-langserver") == 0
	end)
	:display(function()
		local venv_name = require("venv-selector").get_active_venv()
		if venv_name ~= nil then
			venv_name = string.gsub(venv_name, ".*/pypoetry/virtualenvs/*", "")
			venv_name = string.gsub(venv_name, ".*/miniconda3/envs/", "")
			venv_name = string.gsub(venv_name, ".*/miniconda3", "base")
		else
			venv_name = "sys"
		end
		return "pyright" .. "(" .. venv_name .. ")"
	end)
	:on_attach(function(client, bufnr)
		require("venv-selector").retrieve_from_cache()
	end)
lsp("pylance")
	:auto_install(false)
	:on_attach(function()
		keybind_group("<leader>l", "lsp"):register({
			keybind("n", "v", "<cmd>VenvSelect<cr>", "Select virtual environment"),
		})
	end)
	:cond(function()
		return vim.fn.executable("delance-langserver") == 1
	end)
	:display(function()
		local venv_name = require("venv-selector").get_active_venv()
		if venv_name ~= nil then
			venv_name = string.gsub(venv_name, ".*/pypoetry/virtualenvs/*", "")
			venv_name = string.gsub(venv_name, ".*/miniconda3/envs/", "")
			venv_name = string.gsub(venv_name, ".*/miniconda3", "base")
		else
			venv_name = "sys"
		end
		return "pylance" .. "(" .. venv_name .. ")"
	end)
	:on_attach(function(client, bufnr)
		require("venv-selector").retrieve_from_cache()
	end)
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
