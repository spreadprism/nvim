local dap = require("dap")

dap.adapters.codelldb = {
	type = "server",
	port = "13000",
	executable = {
		command = "codelldb",
		args = { "--port", "13000" },
	},
}

dap.adapters.coreclr = {
	type = "executable",
	command = "netcoredbg",
	args = { "--interpreter=vscode" },
}
