require("tokyonight").setup({
	style = "storm",
	styles = {
		floats = "transparent",
	},
	transparent = true,
	on_colors = function(colors) end,
	on_highlights = function(highlights, colors)
		highlights.WhichKeyNormal = { fg = highlights.WhichKeyNormal.fg, bg = colors.none }
		highlights.DropBarFileName = { fg = colors.fg }
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

vim.cmd.colorscheme("tokyonight")
