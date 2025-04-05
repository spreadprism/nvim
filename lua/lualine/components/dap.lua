local component = require("lualine.component"):extend()
local highlight = require("lualine.highlight")

local icon = ""
local default_options = {
	hl = {
		standby = "#565f89",
		initializing = "#ECBE7B",
		active = "#51afef",
	},
}

function component:init(options)
	component.super.init(self, options)
	self.options = vim.tbl_deep_extend("force", default_options, options or {})

	self.highlights = {
		standby = highlight.create_component_highlight_group(
			{ fg = self.options.hl.standby },
			"dap_standby",
			self.options
		),
		initializing = highlight.create_component_highlight_group(
			{ fg = self.options.hl.initializing },
			"dap_init",
			self.options
		),
		active = highlight.create_component_highlight_group(
			{ fg = self.options.hl.active },
			"dap_active",
			self.options
		),
	}
end

function component:update_status()
	if not internal.plugin_loaded("nvim-dap") then
		return " "
	end

	local dap = require("dap")

	local session = dap.session()
	if not session then
		return " "
	end

	return session.config.name
end

function component:apply_icon()
	local hl = self.highlights.standby
	if internal.plugin_loaded("nvim-dap") then
		local dap = require("dap")

		local session = dap.session()
		if session then
			if session.initialized then
				hl = self.highlights.active
			else
				hl = self.highlights.initializing
			end
		end
	end

	self.status = highlight.component_format_highlight(hl) .. icon .. " " .. self.status
end

return component
