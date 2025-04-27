if not nixCats("language.proto") then
	return
end
lsp("buf_ls"):ft("proto"):root_markers("buf.yaml", ".git")
formatter("proto", "buf")
