plugin("luasnip")
	:defer()
	:opts({
		history = true,
		updateevents = "TextChangedI, TextChangedI", -- BUG: nvim-cmp breaks with this setting
	})
	:setup(function()
		require("luasnip.loaders.from_lua").load({ paths = { joinpath(LUA_PATH, "snippets") } })
	end)
