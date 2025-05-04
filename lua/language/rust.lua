if not nixCats("language.rust") then
	return
end
lsp("rust_analyzer")
linter("rust", "clippy")
formatter("rust", "rustfmt")
dap("rust", {
	type = "server",
	port = "${port}",
	executable = {
		command = "codelldb",
		args = { "--port", "${port}" },
	},
	enrich_config = require("internal.dap.enrich_config.cargo"),
})
