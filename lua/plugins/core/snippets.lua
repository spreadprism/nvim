plugin("luasnip"):triggerUIEnter():after(function()
	require("luasnip").setup({
		history = true,
		updateevents = "TextChangedI, TextChangedI", -- BUG: nvim-cmp breaks with this setting
	})

	require("luasnip.loaders.from_lua").load({ paths = joinpath(LUA_PATH, "snippets") })
end)
