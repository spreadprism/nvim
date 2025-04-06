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
		:on_require("kulala")
		:ft("http")

	-- autocmd on buffer enter http ft
	vim.api.nvim_create_autocmd("BufEnter", {
		pattern = { "*.http", "kulala://ui" },
		once = true,
		callback = function(args)
			kopts({ buffer = args.buf }, {
				kmap("n", "<localleader>x", function()
					require("kulala.ui").clear_response_history()
				end, "clear requests"),
				kmap("n", "<localleader>s", function()
					require("kulala").run()
				end, "send request"),
				kmap("n", "<localleader>S", function()
					require("kulala").run_all()
				end, "send all request"),
				kmap("n", "<localleader>r", function()
					require("kulala").replay()
				end, "replay request"),
				kmap("n", "<localleader>i", function()
					require("kulala").inspect()
				end, "inspect request"),
				kmap("n", "<localleader>h", function()
					require("kulala.ui").show_headers()
				end, "show headers"),
				kmap("n", "<localleader>b", function()
					require("kulala.ui").show_body()
				end, "show body"),
				kmap("n", "<localleader>v", function()
					require("kulala.ui").show_verbose()
				end, "show verbose"),
				kmap("n", "<localleader>a", function()
					require("kulala.ui").show_headers_body()
				end, "show all"),
				kmap("n", "<localleader>e", function()
					require("kulala.ui").open()
				end, "close"),
				kmap("n", "<C-q>", function()
					require("kulala.ui").close_kulala_buffer()
					vim.cmd("q")
				end, "close"),
				kmap("n", "<Right>", function()
					require("kulala.ui").show_next()
				end, "next request"),
				kmap("n", "<Left>", function()
					require("kulala.ui").show_previous()
				end, "previous request"),
				kmap("n", "<Down>", function()
					require("kulala").jump_next()
				end, "jump next request"),
				kmap("n", "<Up>", function()
					require("kulala").jump_prev()
				end, "jump previous request"),
			})
		end,
	})
end
