plugin("benlubas/molten-nvim")
	:build(":UpdateRemotePlugins")
	:init(function()
		vim.g.molten_output_win_max_height = 20
		vim.g.molten_auto_open_output = false
		vim.g.molten_wrap_output = true
		vim.g.molten_virt_text_output = true
		vim.g.molten_virt_lines_off_by_1 = true
	end)
	:event("VeryLazy")
	:config(function()
		-- automatically import output chunks from a jupyter notebook
		-- tries to find a kernel that matches the kernel in the jupyter notebook
		-- falls back to a kernel that matches the name of the active venv (if any)

		local imb = function(e) -- init molten buffer
			vim.schedule(function()
				-- TODO: Add kernel change when venv-selector activates an env
				local kernels = vim.fn.MoltenAvailableKernels()
				local venv_name = require("venv-selector").venv()
				if venv_name == nil then
					require("venv-selector.cached_venv").retrieve()
					venv_name = require("venv-selector").venv()
				end

				if venv_name ~= nil then
					venv_name = string.gsub(venv_name, ".*/pypoetry/virtualenvs/*", "")
					venv_name = string.gsub(venv_name, ".*/miniconda3/envs/", "")
					venv_name = string.gsub(venv_name, ".*/miniconda3", "base")

					if vim.tbl_contains(kernels, venv_name) then
						vim.cmd(("MoltenInit %s"):format(venv_name))
						vim.cmd("MoltenImportOutput")
					else
						vim.notify("Failed to find kernel for " .. venv_name)
						vim.notify("pip install ipykernel")
						vim.notify("python -m ipykernel install --user --name {project_name}")
					end
				end
			end)
		end

		-- automatically import output chunks from a jupyter notebook
		vim.api.nvim_create_autocmd("BufAdd", {
			pattern = { "*.ipynb" },
			callback = imb,
		})

		-- we have to do this as well so that we catch files opened like nvim ./hi.ipynb
		vim.api.nvim_create_autocmd("BufEnter", {
			pattern = { "*.ipynb" },
			callback = function(e)
				if vim.api.nvim_get_vvar("vim_did_enter") ~= 1 then
					imb(e)
				end
			end,
		})

		-- automatically export output chunks to a jupyter notebook on write
		vim.api.nvim_create_autocmd("BufWritePost", {
			pattern = { "*.ipynb" },
			callback = function()
				if require("molten.status").initialized() == "Molten" then
					vim.cmd("MoltenExportOutput!")
				end
			end,
		})

		-- Provide a command to create a blank new Python notebook
		-- note: the metadata is needed for Jupytext to understand how to parse the notebook.
		-- if you use another language than Python, you should change it in the template.
		local default_notebook = [[
  {
    "cells": [
     {
      "cell_type": "markdown",
      "metadata": {},
      "source": [
        ""
      ]
     }
    ],
    "metadata": {
     "kernelspec": {
      "display_name": "Python 3",
      "language": "python",
      "name": "python3"
     },
     "language_info": {
      "codemirror_mode": {
        "name": "ipython"
      },
      "file_extension": ".py",
      "mimetype": "text/x-python",
      "name": "python",
      "nbconvert_exporter": "python",
      "pygments_lexer": "ipython3"
     }
    },
    "nbformat": 4,
    "nbformat_minor": 5
  }
]]

		local function new_notebook(filename)
			local path = filename .. ".ipynb"
			local file = io.open(path, "w")
			if file then
				file:write(default_notebook)
				file:close()
				vim.cmd("edit " .. path)
			else
				vim.notify("Error: Could not open new notebook file for writing.")
			end
		end

		vim.api.nvim_create_user_command("NewNotebook", function(opts)
			new_notebook(opts.args)
		end, {
			nargs = 1,
			complete = "file",
		})
	end)

plugin("quarto-dev/quarto-nvim")
	:dependencies({
		plugin("jmbuhr/otter.nvim"):opts({
			verbose = {
				no_code_found = false,
			},
		}),
		"nvim-treesitter/nvim-treesitter",
	})
	:opts({
		lspFeatures = {
			-- NOTE: put whatever languages you want here:
			languages = { "python" },
			chunks = "all",
			diagnostics = {
				enabled = true,
				triggers = { "BufWritePost" },
			},
			completion = {
				enabled = true,
			},
		},
		keymap = {
			-- NOTE: setup your own keymaps:
			-- hover = "K",
			definition = "gd",
			references = "gr",
		},
		codeRunner = {
			enabled = true,
			default_method = "molten",
		},
	})
	:ft({ "markdown", "quarto" })

plugin("GCBallesteros/jupytext.nvim")
	:opts({
		style = "markdown",
		output_extension = "md",
		force_ft = "markdown",
	})
	:event("VeryLazy")

-- TODO: Add tree-sitter objects for cell navigation
-- TODO: Add Hydra code runner
