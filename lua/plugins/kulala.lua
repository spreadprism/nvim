plugin("kulala.nvim")
	:on_require("kulala")
	:ft("http")
	:opts({
		vscode_rest_client_environmentvars = true,
		disable_script_print_output = true,
		-- ui = {
		-- 	winbar = false,
		-- },
	})
	:keymaps({
		k:opts({
			k:group("kulala", "<localleader>", {
				k:map("n", "s", k:require("kulala").run(), "send request"),
				k:map("n", "S", k:require("kulala").run_all(), "send all requests"),
				k:map("n", "r", k:require("kulala").replay(), "replay request"),
				k:map("n", "i", k:require("kulala").inspect(), "inspect request"),
				k:map("n", "x", k:require("kulala.ui").clear_response_history(), "clear requests"),
				k:map("n", "h", k:require("kulala.ui").show_headers(), "show headers"),
				k:map("n", "b", k:require("kulala.ui").show_body(), "show body"),
				k:map("n", "v", k:require("kulala.ui").show_verbose(), "show verbose"),
				k:map("n", "a", k:require("kulala.ui").show_headers_body(), "show all"),
				k:map("n", "e", k:require("kulala.ui").open(), "open explorer"),
			}),
			k:map("n", "<C-q>", function()
				require("kulala.ui").close_kulala_buffer()
				vim.cmd("q")
			end, "close"),
			k:map("n", "<Right>", k:require("kulala.ui").show_next(), "next request"),
			k:map("n", "<Left>", k:require("kulala.ui").show_previous(), "previous request"),
			k:map("n", "<Down>", k:require("kulala.ui").jump_next(), "jump next request"),
			k:map("n", "<Up>", k:require("kulala.ui").jump_prev(), "jump previous request"),
		}):pattern({ "*.http", "kulala://ui" }),
	})
