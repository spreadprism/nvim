plugin("luasnip")
	:event("DeferredUIEnter")
	:opts({
		history = true,
		updateevents = "TextChangedI, TextChangedI",
	})
	:after(function()
		require("luasnip.loaders.from_lua").load({ paths = { vim.fs.joinpath(nixcats.configDir, "lua", "snippets") } })
	end)
