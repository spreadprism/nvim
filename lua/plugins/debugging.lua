local dap = plugin("mfussenegger/nvim-dap"):event("VeryLazy")
local dapui = plugin("rcarriga/nvim-dap-ui"):event("VeryLazy"):dependencies({ dap })
plugin("theHamsta/nvim-dap-virtual-text"):event("VeryLazy"):dependencies({ dap }):opts({
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

plugin("mfussenegger/nvim-dap-python")
	:ft("python")
	:dependencies({ dap, dapui })
	:config("dap-python")
	:opts("~/miniconda3/bin/python")

plugin("leoluz/nvim-dap-go"):ft("go"):dependencies({ dap, dapui }):config(function()
	require("dap-go"):setup({
		experimental = {
			test_table = true,
		},
	})
	require("utils.dap").refresh_configurations("go") -- INFO: Removes the default configs
end)
