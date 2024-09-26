local dap = plugin("mfussenegger/nvim-dap"):event("VeryLazy"):config(function()
	---@diagnostic disable-next-line: different-requires
	require("internal.dap").init_adapters()
	---@diagnostic disable-next-line: different-requires
	require("internal.dap").init_configurations()
	---@diagnostic disable-next-line: different-requires
	local dap = require("dap")
	-- INFO: Force vscode launch.json configs to be before global configs
	local global = dap.providers.configs["dap.global"]
	local launchjson = dap.providers.configs["dap.launch.json"]

	dap.providers.configs["dap.global"] = nil
	dap.providers.configs["dap.launch.json"] = nil

	dap.providers.configs["dap.custom"] = function(bufnr)
		local configs = {}
		configs = vim.list_extend(configs, launchjson())
		configs = vim.list_extend(configs, global(bufnr))
		return configs
	end
	-- Symbols
	vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "ErrorMsg", linehl = "", numhl = "" })
	vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "ErrorMsg", linehl = "", numhl = "" })
	vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "ErrorMsg", linehl = "", numhl = "" })
	vim.fn.sign_define("DapLogPoint", { text = "", texthl = "DiagnosticSignInfo", linehl = "", numhl = "" })
	vim.cmd("highlight DapStoppedSign guifg=#87D285")
	vim.fn.sign_define("DapStopped", { text = "", texthl = "DapStoppedSign", linehl = "DapStoppedSign", numhl = "" })
end)
plugin("rcarriga/nvim-dap-ui"):event("VeryLazy"):dependencies(dap)
plugin("theHamsta/nvim-dap-virtual-text"):event("VeryLazy"):dependencies(dap):opts({
	-- TODO: Add clause to restrict size I don't need to see infinite virtual text
	display_callback = function(variable, buf, stackframe, node, options)
		if options.virt_text_pos == "inline" then
			return "(" .. variable.value .. ")"
		else
			return variable.name .. " = " .. variable.value
		end
	end,

	-- virt_text_pos = "eol",
	virt_text_pos = "inline",
})
