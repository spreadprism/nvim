if os.getenv("KITTY_WINDOW_ID") ~= nil then
	plugin("3rd/image.nvim"):event("VeryLazy"):opts({
		integrations = {
			markdown = {
				filetypes = { "markdown", "quarto" },
			},
			neorg = {
				enabled = false,
			},
			html = {
				enabled = true,
			},
		},
		tmux_show_only_in_active_window = true,
	})
end
