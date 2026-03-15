plugin("tokyonight")
	:opts({
		style = "storm",
		styles = {
			floats = "transparent",
		},
		transparent = true,
		on_colors = function(colors)
			require("internal.loader.highlight").on_colors(colors)
		end,
		on_highlights = function(highlights, colors)
			require("internal.loader.highlight").on_highlights(highlights, colors)

			highlights.WhichKeyNormal = { bg = colors.none }
			highlights.WinBar = { bg = colors.none }
			highlights.WinBarNC = { bg = colors.none }

			highlights.MultiCursorCursor = { fg = colors.black, bg = colors.orange }
		end,
		plugins = { all = true },
	})
	:lazydev({ words = { "colors", "on_highlights", "on_colors" } })
	:after(function(specs)
		_G.colors = require("tokyonight.colors").setup(specs.opts)
		vim.cmd.colorscheme("tokyonight")
	end)
	:lazy(false)
