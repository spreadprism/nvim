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
		end,
		-- INFO: grab all installed plugins, filters out `self` then does { plugin = true } for each of them
		plugins = vim.tbl_deep_extend(
			"keep",
			{
				all = false,
				auto = false,
			},
			(function()
				local t = {}
				for _, v in
					ipairs(vim.tbl_filter(function(plugin)
						return plugin ~= "self"
					end, nixcats.cats.plugins.names))
				do
					t[v] = true
				end
				return t
			end)()
		),
	})
	:after(function(specs)
		_G.colors = require("tokyonight.colors").setup(specs.opts)
		vim.cmd.colorscheme("tokyonight")
	end)
	:lazy(false)
