if nixCats("debugging") then
	local dap_func = require("internal.dap_func")
	plugin("nvim-dap")
		:on_require("dap")
		:triggerUIEnter()
		:after(function()
			local dap = require("dap")
			-- INFO: define symbols
			vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "ErrorMsg", linehl = "", numhl = "" })
			vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "ErrorMsg", linehl = "", numhl = "" })
			vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "ErrorMsg", linehl = "", numhl = "" })
			vim.fn.sign_define("DapLogPoint", { text = "", texthl = "DiagnosticSignInfo", linehl = "", numhl = "" })
			vim.cmd("highlight DapStoppedSign guifg=#87D285")
			vim.fn.sign_define(
				"DapStopped",
				{ text = "", texthl = "DapStoppedSign", linehl = "DapStoppedSign", numhl = "" }
			)
			-- -- INFO: Setup dap plugins startup
			-- dap.listeners.before.attach.trigger_load = function()
			-- end
			-- dap.listeners.before.launch.trigger_load = dap.listeners.before.attach.trigger_load
		end)
		:keys({
			keymap("n", "<F5>", dap_func("continue"), "DAP start / continue"),
			keymap("n", "<F10>", dap_func("step_over"), "DAP step over"),
			keymap("n", "<F11>", dap_func("step_into"), "DAP step into"),
			keymap("n", "<F12>", dap_func("step_out"), "DAP step out"),
			unpack(keymapGroup("<leader>d", "dap", {
				keymap("n", "b", dap_func("toggle_breakpoint"), "toggle breakpoint"),
				keymap("n", "g", dap_func("run_to_cursor"), "run to cursor"),
				keymap("n", "l", dap_func("log_point"), "log point"),
				keymap("n", "cb", dap_func("cond_point"), "conditional breakpoint"),
				keymap("n", "s", dap_func("terminate"), "stop debugging session"),
				keymap("n", "t", dap_func("debug_test"), "debug closest test"),
				keymap("n", "r", dap_func("run_last"), "run last config"),
				keymap("n", "e", dap_func("eval"), "evaluate expression"),
			})),
		})
	plugin("nvim-dap-ui")
		:on_require("dapui")
		:on_plugin("nvim-dap")
		:opts({
			floating = {
				border = "rounded",
			},
			layouts = require("internal.dap_ui").generate_layouts(),
		})
		:keys(keymapGroup("<leader>du", "dapui", {
			keymap("n", "", function()
				require("internal.dap_ui").set_overlay(1)
			end, "dapui repl"),
			keymap("n", "r", function()
				require("internal.dap_ui").set_overlay(1)
			end, "dapui repl"),
			keymap("n", "c", function()
				require("internal.dap_ui").set_overlay(2)
			end, "dapui repl"),
		}))
	local virtual_max_char = 15
	plugin("nvim-dap-virtual-text")
		:opts({
			only_first_definition = false,
			virt_text_pos = "inline",
			display_callback = function(variable, buf, stackframe, node, options)
				local value = variable.value
				if #value > virtual_max_char then
					value = "*"
				end
				if options.virt_text_pos == "inline" then
					return "(" .. value .. ")"
				else
					local name = variable.name
					if #name > virtual_max_char - 3 then
						-- grab the 7 first chars
						name = string.sub(variable.name, 1, 7) .. "..."
					end
					return name .. " = " .. value
				end
			end,
		})
		:on_plugin("nvim-dap")
end
