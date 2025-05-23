plugin("nui.nvim"):config(false)
plugin("dressing.nvim"):opts({
	select = {
		get_config = function(opts)
			if opts.kind == "codeaction" then
				return {
					backend = "telescope",
					telescope = require("telescope.themes").get_cursor({}),
				}
			end
		end,
	},
})
plugin("noice.nvim")
	:for_cat("core")
	:event_defer()
	:dep_on("nui.nvim", "dressing.nvim")
	:on_require("noice")
	:keys({
		kgroup("<leader>n", "notifications", {}, {
			kmap("n", "d", kcmd("Noice dismiss"), "dismiss notifications"),
			kmap("n", "l", kcmd("Noice last"), "last notifications"),
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
			-- hover = { enabled = false },
		},
		views = {
			mini = {
				win_options = {
					winblend = 0,
				},
			},
		},
		routes = {
			-- INFO: Remove all saved message
			{
				filter = {
					event = "msg_show",
					kind = "",
					find = "No information available",
				},
				opts = { skip = true },
			},
			{
				filter = {
					event = "msg_show",
					find = "written",
				},
				opts = { skip = true },
			},
			{
				filter = {
					event = "msg_show",
					find = "python.addImport",
				},
				opts = { skip = true },
			},
			{
				filter = {
					event = "msg_show",
					find = "No diagnostics found",
				},
				opts = { skip = true },
			},
			{
				filter = {
					event = "msg_show",
					find = "No results for",
				},
				opts = { skip = true },
			},
			{
				filter = {
					event = "msg_show",
					find = "Hop",
				},
				opts = { skip = true },
			},
			{
				filter = {
					event = "msg_show",
					find = "Errors in request",
				},
				opts = { skip = true },
			},
		},
	})
