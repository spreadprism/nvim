plugin("noice")
	:event("DeferredUIEnter")
	:keymaps({
		k:group("notification", "<leader>n", {
			k:map("n", "d", k:lazy("noice").cmd("dismiss"), "Dismiss"),
			k:map("n", "l", k:lazy("noice").cmd("last"), "Last"),
		}),
	})
	:opts({
		cmdline = {
			view = "cmdline",
		},
		-- add any options here
		presets = {
			bottom_search = true, -- use a classic bottom cmdline for search
			command_palette = false, -- position the cmdline and popupmenu together
			long_message_to_split = true, -- long messages will be sent to a split
			inc_rename = false, -- enables an input dialog for inc-rename.nvim
			lsp_doc_border = true, -- add a border to hover docs and signature help
		},
		lsp = {
			progress = {
				enabled = true,
			},
			signature = {
				auto_open = {
					enabled = false,
				},
			},
		},
		views = {
			mini = {
				win_options = {
					winblend = 0,
				},
			},
		},
		routes = vim.tbl_map(function(msg)
			return {
				filter = {
					event = "msg_show",
					find = msg,
				},
				opts = { skip = true },
			}
		end, { -- filter out these messages
			"No information available",
			"written",
			"No diagnostics found",
			"No results for",
			"Hop",
		}),
	})
