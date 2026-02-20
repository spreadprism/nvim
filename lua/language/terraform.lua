if nixCats("language.terraform") then
	lsp("tofu_ls")
	formatter("terraform", "terraform_fmt")
end
