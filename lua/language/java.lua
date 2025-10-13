if not nixCats("language.java") then
	return
end
plugin("jdtls"):event_defer():config(false)
lsp("jdtls"):init_options({
	bundles = { exec("java-debug-path") },
})
