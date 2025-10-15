if not nixCats("core.search") then
	return
end

plugin("keytrail"):event_defer():opts({
	key_mapping = "fk",
	hover_delay = 9999999, -- HACK: can't disable the hover, so I just jacked the delay
	filetypes = { yaml = true, json = true },
})
plugin("snacks")
	:on_require("snacks")
	:opts({
		picker = {
			main = {
				file = false,
			},
			enabled = true,
			matcher = {
				frecency = true,
			},
		},
	})
	:setup(function()
		vim.ui.select = require("snacks.picker").select
	end)
	:event_defer()
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
			kmap("n", "b", klazy("snacks.picker").buffers(), "buffers"),
			kmap("n", "c", klazy("snacks.picker").commands(), "commands"),
			kmap("n", "k", kcmd("KeyTrailJump"), "key"),
		}),
	})
