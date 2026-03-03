lsp("gopls"):root_markers({ "go.work", "go.mod" }):settings({
	gopls = {
		directoryFilters = {
			"-/nix/**",
			string.format("-%s/**", os.getenv("GOPATH")),
		},
		["ui.inlayhint.hints"] = {
			constantValues = true,
			rangeVariableTypes = true,
		},
	},
})
linter("go", "golangcilint")
formatter("go", "gofumpt")
d:adapter("delve", function(callback, config)
	---@type dap.ServerAdapter
	local adapter = {
		type = "server",
	}

	if config.mode == "remote" and config.request == "attach" then
		adapter.host = config.host or "127.0.0.1"
		adapter.port = config.port or "38697"
	else
		adapter.port = "${port}"
		adapter.executable = {
			command = "dlv",
			args = { "dap", "-l", "127.0.0.1:${port}", "--log", "--log-output=dap" },
			detached = vim.fn.has("win32") == 0,
		}
	end
	callback(adapter)
end):link("go")
