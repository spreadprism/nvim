if nixCats("requests") then
	-- 󰏚
	plugin("kulala")
		:opts({
			vscode_rest_client_environmentvars = true,
			disable_script_print_output = true,
			ui = {
				winbar = false,
			},
		})
		:event_ui()

	-- autocmd on buffer enter http ft
	vim.api.nvim_create_autocmd("BufEnter", {
		pattern = { "*.http", "kulala://ui" },
		once = true,
		callback = function(args)
			local opts = { buffer = args.buf }
			vim.keymap.set("n", "<localleader>x", function()
				require("kulala.ui").clear_response_history()
			end, vim.tbl_extend("keep", opts, { desc = "clear request history" }))
			vim.keymap.set("n", "<localleader>s", function()
				require("kulala").run()
			end, vim.tbl_extend("keep", opts, { desc = "send request" }))
			-- kgroup("<localleader>", "http", {
			-- 	keymap("n", "x", function()
			-- 		require("kulala.ui").clear_response_history()
			-- 	end, "send request", { buffer = args.buf }),
			-- 	keymap("n", "s", function()
			-- 		require("kulala").run()
			-- 	end, "send request", { buffer = args.buf }),
			-- 	keymap("n", "S", function()
			-- 		require("kulala").run_all()
			-- 	end, "send all request", { buffer = args.buf }),
			-- 	keymap("n", "r", function()
			-- 		require("kulala").replay()
			-- 	end, "resend last request", { buffer = args.buf }),
			-- 	keymap("n", "i", function()
			-- 		require("kulala").inspect()
			-- 	end, "inspect current request", { buffer = args.buf }),
			-- 	keymap("n", "h", function()
			-- 		require("kulala.ui").show_headers()
			-- 	end, "show headers", { buffer = args.buf }),
			-- 	keymap("n", "b", function()
			-- 		require("kulala.ui").show_body()
			-- 	end, "show body", { buffer = args.buf }),
			-- 	keymap("n", "a", function()
			-- 		require("kulala.ui").show_headers_body()
			-- 	end, "show header and body", { buffer = args.buf }),
			-- 	keymap("n", "v", function()
			-- 		require("kulala.ui").show_verbose()
			-- 	end, "show verbose", { buffer = args.buf }),
			-- })
			-- keymapLoad({
			-- 	keymap("n", "<C-q>", function()
			-- 		require("kulala.ui").close_kulala_buffer()
			-- 		vim.cmd("q")
			-- 	end, "Next request", { buffer = args.buf }),
			-- 	keymap("n", "<Right>", function()
			-- 		require("kulala.ui").show_next()
			-- 	end, "Next request", { buffer = args.buf }),
			-- 	keymap("n", "<Left>", function()
			-- 		require("kulala.ui").show_previous()
			-- 	end, "Previous request", { buffer = args.buf }),
			-- 	keymap("n", "<Down>", function()
			-- 		require("kulala").jump_next()
			-- 	end, "Jump next request", { buffer = args.buf }),
			-- 	keymap("n", "<Up>", function()
			-- 		require("kulala").jump_prev()
			-- 	end, "Jump previous request", { buffer = args.buf }),
			-- })
		end,
	})
end
