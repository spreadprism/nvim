local attached = false
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("copilot-status", {}),
	desc = "Update copilot attached status",
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client and client.name == "copilot" then
			attached = true
			require("copilot.status").register_status_notification_handler(function()
				vim.cmd("redrawstatus")
			end)
		end
	end,
})
return {
	fallthrough = false,
	static = {
		icons = {
			enabled = " ",
			disabled = " ",
		},
	},
	{
		condition = function()
			return not (plugin_loaded("copilot") and attached)
		end,
		symbol = function(self)
			return self.disabled
		end,
		provider = " ",
		hl = { fg = colors.comment },
	},
	{
		init = function(self)
			local client, api = require("copilot.client"), require("copilot.api")

			self.loading = false

			if client.is_disabled() then
				return
			end

			if not client.buf_is_attached(self.bufnr) then
				return
			end

			self.loading = api.status.data.status == "InProgress"
		end,
		provider = " ",
		hl = function(self)
			if self.loading then
				return { fg = colors.blue }
			else
				return { fg = colors.comment }
			end
		end,
	},
}
