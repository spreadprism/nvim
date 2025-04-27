if not nixCats("language.rust") then
	return
end
lsp("rust_analyzer")
linter("rust", "clippy")
formatter("rust", "rustfmt")
for _, adapter in ipairs({ "rust", "codelldb", "lldb" }) do
	dap(adapter, {
		type = "server",
		port = "13000",
		executable = {
			command = "codelldb",
			args = { "--port", "13000" },
		},
	})
end
