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
	:setup(function()
		vim.ui.select = require("snacks.picker").select
	end)
	:keys({
		kmap("n", "<M-r>", klazy("snacks.picker").lines(), "find row"),
		kmap("n", "<M-f>", klazy("snacks.picker").grep(), "find"),
		kmap("n", "<leader><leader>", klazy("snacks.picker").files(), "files"),
		kgroup("<leader>f", "find", {}, {
			kmap("n", "f", klazy("snacks.picker").files(), "files"),
			kmap("n", "l", klazy("snacks.picker").resume(), "last"),
			kmap("n", "s", klazy("snacks.picker").lsp_symbols(), "symbols"),
			kmap("n", "p", klazy("snacks.picker").projects(), "projects"),
			kmap("n", "d", klazy("snacks.picker").diagnostics_buffer(), "diagnostics buffer"),
			kmap("n", "D", klazy("snacks.picker").diagnostics(), "diagnostics"),
			kmap("n", "c", klazy("snacks.picker").commands(), "commands"),
		}),
	})
