-- Based on https://github.com/AndreM222/copilot-lualine
local component = require("lualine.component"):extend()
local highlight = require("lualine.highlight")

local default_options = {
	icons = {
		enabled = " ",
		disabled = " ",
	},
	hl = {
		standby = "#565f89",
		active = "#51afef",
	},
}

-- Whether copilot is attached to a buffer
local attached = false

function component:init(options)
	component.super.init(self, options)
	self.options = vim.tbl_deep_extend("force", default_options, options or {})

	self.highlights = {
		standby = highlight.create_component_highlight_group(
			{ fg = self.options.hl.standby },
			"copilot_standby",
			self.options
		),
		processing = highlight.create_component_highlight_group(
			{ fg = self.options.hl.active },
			"copilot_active",
			self.options
		),
	}

	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("copilot-status", {}),
		desc = "Update copilot attached status",
		callback = function(args)
			local client = vim.lsp.get_client_by_id(args.data.client_id)
			if client and client.name == "copilot" then
				attached = true
				require("copilot.status").register_status_notification_handler(function()
					require("lualine").refresh()
				end)
				return true
			end
			return false
		end,
	})
end

local function is_loading()
	local client, api = require("copilot.client"), require("copilot.api")
	if client.is_disabled() then
		return false
	end
	if not client.buf_is_attached(vim.api.nvim_get_current_buf()) then
		return false
	end

	return api.status.data.status == "InProgress"
end

function component:update_status()
	if not attached or not internal.plugin_loaded("copilot") then
		return highlight.component_format_highlight(self.highlights.standby) .. self.options.icons.disabled
	end

	if is_loading() then
		return highlight.component_format_highlight(self.highlights.processing) .. self.options.icons.enabled
	else
		return highlight.component_format_highlight(self.highlights.standby) .. self.options.icons.enabled
	end
end

return component
