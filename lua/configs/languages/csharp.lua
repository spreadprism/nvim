dap("coreclr", {
	type = "executable",
	command = "netcoredbg",
	args = { "--interpreter=vscode" },
}):mason("netcoredbg")
