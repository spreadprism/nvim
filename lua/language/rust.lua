if not nixCats("language.rust") then
	return
end
lsp("rust_analyzer")
linter("rust", "clippy")
formatter("rust", "rustfmt")
for _, adapter in ipairs({ "rust", "codelldb", "lldb" }) do
	dap(adapter, {
		type = "server",
		port = "${port}",
		executable = {
			command = "codelldb",
			args = { "--port", "${port}" },
		},
		enrich_config = function(config, on_config)
			-- If the configuration(s) in `launch.json` contains a `cargo` section
			-- send the configuration off to the cargo_inspector.
			if config["cargo"] ~= nil then
				on_config(require("internal.dap_rust").cargo_inspector(config))
			end
		end,
	})
end
