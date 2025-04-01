---@enum CopilotStatus
local icons = {
	enabled = " ",
	sleep = " ",
	disabled = " ",
	warning = " ",
	unknown = " ",
}
local colors = {
	enabled = Colors.blue,
	sleep = "#565f89",
	disabled = "#565f89",
	warning = Colors.orange,
	unknown = "#565f89",
}
local attached = false
local function status()
	local copilot_loaded = package.loaded["copilot"] ~= nil
	if not copilot_loaded or not attached then
		return "unknown"
	end
	local api = require("copilot.api")
	local client = require("copilot.client")

	if api.status.data.status == "InProgress" then
		return "enabled"
	end
end

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("copilot-status", {}),
	desc = "Update copilot attached status",
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client and client.name == "copilot" then
			attached = true
			require("copilot.api").register_status_notification_handler(function()
				require("lualine").refresh()
			end)
			return true
		end
		return false
	end,
})

return {
	function()
		return icons[status()]
	end,
	separator = "",
	padding = { right = 0, left = 1 },
	color = function(_)
		return { fg = colors[status()] }
	end,
}
