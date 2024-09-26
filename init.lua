require("init_globals")
require("init_lazy")
require("init_options")

vim.api.nvim_create_autocmd("User", {
	pattern = "LazyVimStarted",
	once = true,
	callback = function()
		local ok, _ = pcall(require, "init_keybinds")
	end,
})
