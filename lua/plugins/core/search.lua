if not nixCats("core.search") then
	return
end

plugin("snacks")
	:on_require("snacks")
	:opts({
		picker = {
			enabled = true,
			matcher = {
				frecency = true,
			},
		},
	})
	:keys({
		kmap("n", "<M-f>", klazy("snacks.picker").grep(), "find"),
		kgroup("<leader>f", "find", {}, {
			kmap("n", "f", klazy("snacks.picker").files({}), "files"),
			kmap("n", "l", klazy("snacks.picker").resume(), "last"),
			kmap("n", "s", klazy("snacks.picker").lsp_symbols(), "symbols"),
			kmap("n", "d", klazy("snacks.picker").diagnostics_buffer(), "diagnostics buffer"),
			kmap("n", "D", klazy("snacks.picker").diagnostics(), "diagnostics"),
		}),
	})
