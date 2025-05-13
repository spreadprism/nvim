if nixCats("terraform") then
	lsp("terraformls")
	formatter("terraform", "terraform_fmt")
end
