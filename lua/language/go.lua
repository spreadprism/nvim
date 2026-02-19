lsp("gopls"):ft({ "go", "gomod", "gosum", "gowork" }):root_markers({ "go.work", "go.mod", ".git" }):settings({
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
	if config.mode == "remote" and config.request == "attach" then
		callback({
			type = "server",
			host = config.host or "127.0.0.1",
			port = config.port or "38697",
		})
	else
		callback({
			type = "server",
			port = "${port}",
			executable = {
				command = "dlv",
				args = { "dap", "-l", "127.0.0.1:${port}", "--log", "--log-output=dap" },
				detached = vim.fn.has("win32") == 0,
			},
		})
	end
end):link("go")
