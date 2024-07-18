local fs = require("utils.filesystem")

local conda_venv_python = vim.fs.joinpath(os.getenv("HOME"), "miniconda3", "envs", "nvim", "bin", "python")

if not fs.exists(conda_venv_python) then
	print("We don't have a venv for python")
else
	vim.g.python3_host_prog = conda_venv_python
end
