if not nixCats("language.rust") then
	return
end
lsp("rust_analyzer")
linter("rust", "clippy")
formatter("rust", "rustfmt")
local opts = {
	type = "server",
	port = "13000",
	executable = {
		command = "codelldb",
		args = { "--port", "13000" },
	},
}
dap("codelldb", opts)
dap("lldb", opts)
