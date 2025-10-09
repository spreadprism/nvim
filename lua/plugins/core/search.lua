if not nixCats("core.search") then
	return
end

plugin("snacks"):on_require("snacks"):opts({
	picker = { enabled = true },
})
