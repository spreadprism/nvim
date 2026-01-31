local M = {}
---@type fun(highlights: tokyonight.Highlights, colors: ColorScheme)[]
local plugins_highlights = {}
---@type fun(colors: ColorScheme)[]
local plugins_colors = {}

function M.plugins_highlight(fn)
	table.insert(plugins_highlights, fn)
end

function M.plugins_color(fn)
	table.insert(plugins_colors, fn)
end

---@param highlights tokyonight.Highlights
---@param colors ColorScheme
function M.on_highlights(highlights, colors)
	for _, fn in ipairs(plugins_highlights) do
		fn(highlights, colors)
	end
end

---@param colors ColorScheme
function M.on_colors(colors)
	for _, fn in ipairs(plugins_colors) do
		fn(colors)
	end
end

return M
