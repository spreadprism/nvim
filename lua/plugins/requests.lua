if nixCats("requests") then
	-- 󰏚
	plugin("kulala")
		:opts({
			vscode_rest_client_environmentvars = true,
		})
		:triggerUIEnter()

	-- autocmd on buffer enter http ft
	vim.api.nvim_create_autocmd("BufEnter", {
		pattern = { "*.http", "kulala://ui" },
		once = true,
		callback = function(args)
			keymapLoad({
				keymap("n", "<localleader>s", function()
					require("kulala").run()
				end, "send request", { buffer = args.buf }),
				keymap("n", "<localleader>s", function()
					require("kulala").run_all()
				end, "send all request", { buffer = args.buf }),
				keymap("n", "<localleader>i", function()
					require("kulala").inspect()
				end, "inspect current request", { buffer = args.buf }),
				keymap("n", "<Right>", function()
					require("kulala.ui").show_next()
				end, "Next request", { buffer = args.buf }),
				keymap("n", "<Left>", function()
					require("kulala.ui").show_previous()
				end, "Previous request", { buffer = args.buf }),
			})
		end,
	})
end
