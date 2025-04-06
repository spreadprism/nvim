local component = require("lualine.component"):extend()
local highlight = require("lualine.highlight")

local icons = {
	[1] = "󰲠",
	[2] = "󰲢",
	[3] = "󰲤",
	[4] = "󰲦",
	[5] = "󰲨",
	[6] = "󰲪",
	[7] = "󰲬",
	[8] = "󰲮",
	[9] = "󰲰",
}

local default_options = {
	mark_color = "#ec5f67",
}

function component:init(options)
	component.super.init(self, options)
	self.options = vim.tbl_deep_extend("force", default_options, options or {})
	self.highlights = {
		mark = highlight.create_component_highlight_group({ fg = "#ec5f67" }, "harpoon_mark", self.options),
	}
end

function component:update_status()
	if not internal.plugin_loaded("harpoon") then
		return ""
	end

	local harpoon = require("harpoon")

	local marks = harpoon:list().items
	local current_buffer = vim.fn.expand("%s"):gsub(vim.fn.getcwd() .. "/", "")
	for i, mark in ipairs(marks) do
		if current_buffer == mark.value then
			return highlight.component_format_highlight(self.highlights.mark) .. icons[i]
		end
	end
	return ""
end

return component
