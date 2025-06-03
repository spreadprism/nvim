if not nixCats("language.go") then
	return
end
lsp("gopls"):ft("go", "gomod", "gosum", "gowork", "gotmpl"):root_markers("go.work", "go.mod", ".git"):settings({
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
neotest("neotest-golang")({
	dap_mode = "manual",
	dap_manual_config = {
		type = "go",
		name = "neotest",
		request = "launch",
		mode = "test",
		outputMode = "remote",
	},
})
---@diagnostic disable-next-line: param-type-mismatch
dap("go", {
	type = "server",
	port = "${port}",
	executable = {
		args = { "dap", "-l", "127.0.0.1:${port}" },
		command = "dlv",
		cwd = cwd(),
	},
	enrich_config = require("internal.dap.enrich_config.go"),
})
