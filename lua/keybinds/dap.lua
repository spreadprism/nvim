local dap = require("dap")
keybind("n", "<F5>", dap.continue, "DAP start / continue"):register()
keybind("n", "<F10>", dap.step_over, "DAP step_over"):register()
keybind("n", "<F11>", dap.step_into, "DAP step_into"):register()
keybind("n", "<F12>", dap.step_out, "DAP step_out"):register()
keybind_group("<leader>d", "DAP"):register({
	keybind("n", "b", dap.toggle_breakpoint, "DAP toggle breakpoint"),
	keybind("n", "g", dap.run_to_cursor, "DAP go to cursor"),
	keybind("n", "l", function()
		local log_message = vim.fn.input("Log message: ")
		if log_message ~= nil and log_message ~= "" then
			dap.set_breakpoint(nil, nil, log_message)
		end
	end, "DAP log_point"),
	keybind("n", "cb", function()
		local condition = vim.fn.input("Condition: ")
		if condition ~= nil and condition ~= "" then
			dap.set_breakpoint(condition)
		end
	end, "DAP conditional breakpoint"),
	keybind("n", "r", dap.run_last, "DAP run last config"),
	keybind("n", "e", function()
		require("dapui").eval()
	end, "DAP run last config"),
	keybind("n", "s", function()
		dap.terminate()
		require("dapui").close()
	end, "DAP stop"),
	keybind("n", "t", function()
		local filetype = vim.bo[vim.api.nvim_get_current_buf()].filetype
		if filetype == "go" then
			require("dap-go").debug_test()
		else
			require("neotest").run.run({ strategy = "dap" })
		end
	end, "Debug current test"),
})
