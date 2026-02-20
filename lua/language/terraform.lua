if nixCats("language.terraform") then
	lsp("tofu_ls")
	linter("terraform", "tflint")
	formatter("terraform", "terraform_fmt")
end
