plugin("stevearc/dressing.nvim"):event("VeryLazy")
plugin("MunifTanjim/nui.nvim"):event("VeryLazy")
plugin("brenoprata10/nvim-highlight-colors"):event("VeryLazy"):opts({
	render = "virtual",
	virtual_symbol = "",
	virtual_symbol_position = "eol",
	virtual_symbol_prefix = "",
})
plugin("karb94/neoscroll.nvim"):event("VeryLazy"):opts({ stop_eof = false, hide_cursor = false }) -- BUG: Cursor is perm hidden
plugin("nvim-lualine/lualine.nvim"):event("VeryLazy"):dependencies("ofseed/copilot-status.nvim")
plugin("lewis6991/hover.nvim"):event("VeryLazy"):opts({
	init = function()
		require("hover.providers.lsp")
	end,
	preview_opts = {
		border = "rounded",
	},
	title = false,
})
plugin("utilyre/barbecue.nvim"):event("BufRead"):dependencies({
	"SmiteshP/nvim-navic",
	"nvim-tree/nvim-web-devicons",
})
plugin("rcarriga/nvim-notify")
	:event("VeryLazy")
	:opts({ render = "compact", background_colour = "#000000", stage = "slide" })
plugin("folke/which-key.nvim"):event("VeryLazy")
plugin("echasnovski/mini.ai"):event("VeryLazy"):opts({
	custom_textobjects = {
		-- f = spec_treesitter({ a = "@function.outer", i = "@function.inner" }),
		c = false,
		p = false,
		i = false,
	},
})
plugin("echasnovski/mini.indentscope")
	:event("VeryLazy")
	:init(function()
		vim.api.nvim_create_autocmd("FileType", {
			pattern = {
				"",
				"help",
				"leetcode.nvim",
				"alpha",
				"dashboard",
				"neo-tree",
				"Trouble",
				"trouble",
				"lazy",
				"mason",
				"notify",
				"toggleterm",
				"lazyterm",
			},
			callback = function()
				vim.b.miniindentscope_disable = true
			end,
		})
	end)
	:opts({})
plugin("folke/noice.nvim"):event("VeryLazy"):opts({
	-- add any options here
	presets = {
		bottom_search = false, -- use a classic bottom cmdline for search
		command_palette = false, -- position the cmdline and popupmenu together
		long_message_to_split = true, -- long messages will be sent to a split
		inc_rename = false, -- enables an input dialog for inc-rename.nvim
		lsp_doc_border = false, -- add a border to hover docs and signature help
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
	},
})
