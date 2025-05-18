if nixCats("language.terraform") then
	lsp("terraformls")
	formatter("terraform", "terraform_fmt")
end
