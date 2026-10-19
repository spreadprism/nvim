plugin("noice")
	:event("DeferredUIEnter")
	:keymaps({
		k:group("notification", "<leader>n", {
			k:map("n", "d", k:require("noice").cmd("dismiss"), "Dismiss"),
			k:map("n", "l", k:require("noice").cmd("last"), "Last"),
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
		-- the runtime checker complains that `vim.lsp.buf.signature_help` was
		-- "overwritten by another plugin" whenever something else wraps it (the
		-- snacks profiler does exactly that). `:checkhealth noice` still works.
		health = {
			checker = false,
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
		routes = vim.list_extend(
			(function()
				local skipped = { -- filter out these messages
					"No information available",
					"Empty hover response",
					"written",
					"No diagnostics found",
					"No results for",
					"No textobject",
					"Hop",
				}
				local routes = {}
				for _, msg in ipairs(skipped) do
					-- these arrive either as `:echo`-style messages or through
					-- `vim.notify` (lsp hover does the latter), so skip both.
					for _, event in ipairs({ "msg_show", "notify" }) do
						table.insert(routes, {
							filter = { event = event, find = msg },
							opts = { skip = true },
						})
					end
				end
				return routes
			end)(),
			{
				{
					filter = {
						event = "lsp",
						kind = "progress",
						cond = function(message)
							local client = vim.tbl_get(message.opts, "progress", "client")
							return client == "jdtls" or client == "basedpyright"
						end,
					},
					opts = { skip = true },
				},
			}
		),
	})
