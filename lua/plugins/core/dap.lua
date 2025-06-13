if nixCats("core.debugging") then
	local dap_func = require("internal.dap_func")
	plugin("nvim-dap")
		:on_require("dap")
		:config(function()
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
			require("internal.dap").init_adapters()
			require("overseer").enable_dap()
		end)
		:keys({
			kmap("n", "<F5>", dap_func("continue"), "DAP start / continue"),
			kmap("n", "<F10>", dap_func("step_over"), "DAP step over"),
			kmap("n", "<F11>", dap_func("step_into"), "DAP step into"),
			kmap("n", "<F12>", dap_func("step_out"), "DAP step out"),
			kgroup("<leader>d", "dap", {}, {
				kmap("n", "b", dap_func("toggle_breakpoint"), "toggle breakpoint"),
				kmap("n", "g", dap_func("run_to_cursor"), "run to cursor"),
				kmap("n", "l", dap_func("log_point"), "log point"),
				kmap("n", "cb", dap_func("cond_point"), "conditional breakpoint"),
				kmap("n", "s", dap_func("terminate"), "stop debugging session"),
				kmap("n", "t", dap_func("debug_test"), "debug closest test"),
				kmap("n", "r", dap_func("run_last"), "run last config"),
				kmap("n", "e", dap_func("eval"), "evaluate expression"),
			}),
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
		:setup(function()
			local elements = require("dapui").elements
			---@diagnostic disable-next-line: inject-field
			elements.repl.allow_without_session = true
			---@diagnostic disable-next-line: inject-field
			elements.console.allow_without_session = true
		end)
		:keys({
			kmap("n", "<M-c>", function()
				require("dapui").float_element("repl", {
					width = get_width(0.9),
					height = get_height(0.9),
					enter = true,
					position = "center",
				})
			end, "dap console (repl)"),
			kmap("n", "<M-C>", function()
				require("dapui").float_element("console", {
					width = get_width(0.9),
					height = get_height(0.9),
					enter = true,
					position = "center",
				})
			end, "dap console (console)"),
		})
	local virtual_max_char = 20
	plugin("nvim-dap-virtual-text")
		:opts({
			only_first_definition = false,
			virt_text_pos = "inline",
			show_stop_reason = false,
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
