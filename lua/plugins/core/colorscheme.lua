---@return table
local function colorscheme_plugins()
	local plugins = {
		all = false,
		auto = false,
	}

	local names = vim.tbl_filter(function(plugin)
		return plugin ~= "self"
	end, nixcats.cats.plugins.names)

	for _, k in ipairs(names) do
		plugins[k] = true
	end

	return plugins
end

---@param colors ColorScheme
local function on_colors(colors) end

---@param highlights table<string, string|tokyonight.Highlights>
---@param colors ColorScheme
local function on_highlights(highlights, colors)
	--WhichKeyNormal
	highlights.WhichKeyNormal = { fg = highlights.WhichKeyNormal.fg, bg = colors.none }
end

require("tokyonight").setup({
	style = "storm",
	styles = {
		floats = "transparent",
	},
	transparent = true,
	plugins = colorscheme_plugins(),
	on_colors = on_colors,
	on_highlights = on_highlights,
})

vim.cmd.colorscheme("tokyonight")
