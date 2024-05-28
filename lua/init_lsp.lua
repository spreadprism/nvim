lsp("lua_ls")
lsp("taplo")
lsp("bashls", "bash-language-server"):filetypes({ "sh", "zsh" })
lsp("gopls")
lsp("jsonls", "json-lsp")
lsp("yamlls", "yaml-language-server")
lsp("marksman")
lsp("rust_analyzer")
lsp("docker_compose_language_service", "docker-compose-language-service")
lsp("dockerls", "dockerfile-language-server")
lsp("tsserver", "typescript-language-server")
lsp("clangd"):capabilities({ offsetEncoding = { "utf-16" } })
-- INFO: Register language servers from submodules
for _, lsp_config_file in ipairs(require("utils.module").submodules("language_servers")) do
	require("language_servers." .. lsp_config_file)
end
