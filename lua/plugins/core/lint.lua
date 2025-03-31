plugin("nvim-lint"):on_require("lint"):after(function()
	local linters = {}
	if nixCats("go") then
		linters.go = { "golangcilint" }
	end
	require("lint").linters_by_ft = linters
end)
