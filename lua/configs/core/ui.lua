local devicon = plugin("nvim-tree/nvim-web-devicons"):optional(true):config(function()
	local devicons = require("nvim-web-devicons")
	local devicon_utils = require("internal.devicon")

	local get_icon = devicons.get_icon
	devicons.get_icon = function(name, ext, opts)
		return get_icon(name, ext or devicon_utils.get_ext(name), opts)
	end

	local get_icon_colors = devicons.get_icon_colors
	devicons.get_icon_colors = function(name, ext, opts)
		return get_icon_colors(name, ext or devicon_utils.get_ext(name), opts)
	end

	devicons.setup({
		default = true,
		strict = false,
		override_by_filename = require("icons.filename"),
		override_by_extension = require("icons.extension"),
	})
	require("nvim-web-devicons").set_icon_by_filetype(require("icons.filetype"))
end)
plugin("karb94/neoscroll.nvim"):event("VeryLazy"):opts({ stop_eof = false })
plugin("MunifTanjim/nui.nvim"):event("VeryLazy")
plugin("stevearc/dressing.nvim"):event("VeryLazy")
plugin("brenoprata10/nvim-highlight-colors"):event("VeryLazy"):opts({
	render = "virtual",
	virtual_symbol = "",
	virtual_symbol_position = "eow",
	virtual_symbol_prefix = " ",
	virtual_symbol_suffix = " ",
})
-- PERF: test perf?
-- HACK: bruh
-- TODO: wew
-- NOTE:  sdkfj dkfjskdfj
-- FIX: fixed
-- WARNING: test done
plugin("folke/todo-comments.nvim"):dependencies("nvim-lua/plenary.nvim"):event("VeryLazy"):opts({
	highlight = {
		multiline = false,
	},
})
plugin("lewis6991/hover.nvim"):event("VeryLazy"):opts({
	init = function()
		require("hover.providers.lsp")
	end,
	preview_opts = {
		border = "rounded",
	},
	title = false,
})
plugin("utilyre/barbecue.nvim")
	:event("VeryLazy")
	:dependencies({
		"SmiteshP/nvim-navic",
		devicon,
	})
	:config(function()
		require("barbecue").setup({
			create_autocmd = false, -- prevent barbecue from updating itself automatically
			attach_navic = false,
			exclude_filetypes = { "netrw", "toggleterm", "NeogitStatus" },
		})
		vim.api.nvim_create_autocmd({
			"WinScrolled", -- or WinResized on NVIM-v0.9 and higher
			"BufWinEnter",
			"CursorHold",
			"BufEnter",
			"InsertLeave",
			-- include this if you have set `show_modified` to `true`
			"BufModifiedSet",
		}, {
			group = vim.api.nvim_create_augroup("barbecue.updater", {}),
			callback = function()
				require("barbecue.ui").update()
			end,
		})
	end)
plugin("nvimdev/dashboard-nvim"):event("VimEnter"):dependencies({ devicon, "chrisbra/Colorizer" }):config(function()
	require("dashboard").setup({
		theme = "doom",
		hide = {
			statusline = false,
		},
		---@diagnostic disable-next-line: different-requires
		config = require("internal.dashboard").generate_config_config(),
		---@diagnostic disable-next-line: different-requires
		preview = require("internal.dashboard").generate_config_preview(),
	})
end)
plugin("nvim-lualine/lualine.nvim")
	:dependencies({
		"SmiteshP/nvim-navic",
		devicon,
	})
	:event("VeryLazy")
	:config(function()
		local ll_utils = require("internal.lualine_utils")
		require("lualine").setup({
			options = {
				theme = "auto",
				globalstatus = true,
				disabled_filetypes = { statusline = { "dashboard", "alpha" } },
				-- INFO: prevent telescope from stealing focus
				ignore_focus = { "TelescopePrompt", "Mason" },
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = {
					{ "branch", on_click = ll_utils.cmd_on_click("Neogit") },
					{
						"filetype",
						icon_only = true,
						separator = "",
						padding = { left = 1, right = 1 },
						cond = ll_utils.display_file,
					},
					{
						"filename",
						path = 0,
						separator = "",
						padding = { left = 0, right = 1 },
						symbols = { modified = Symbols.modified, readonly = Symbols.readonly, unnamed = "" },
						cond = ll_utils.display_file,
					},
					{
						function()
							local ok, harpoon = pcall(require, "harpoon")

							if not ok then
								return ""
							end

							local marks = harpoon:list().items
							local current_buffer = vim.fn.expand("%s"):gsub(vim.fn.getcwd() .. "/", "")

							for _, mark in ipairs(marks) do
								if current_buffer == mark.value then
									return ""
								end
							end
							return ""
						end,
						color = { fg = Colors.red },
						cond = function()
							local ok, _ = pcall(require, "harpoon")
							return ok
						end,
						separator = "",
						padding = { left = 0, right = 1 },
					},
				},
				lualine_c = {},
				lualine_x = {
					{
						"overseer",
						unique = true,
						symbols = {
							[require("overseer").STATUS.RUNNING] = "󰦖 ",
						},
					},

					{
						-- INFO: current lsp
						function()
							local all_clients = vim.lsp.get_clients({ bufnr = vim.fn.bufnr() }) or {}

							local displays = {}
							for _, client in pairs(all_clients) do
								local name = client.name
								if string.match(name, "otter%-ls") then
									name = "otter-ls"
									local venv_name = require("venv-selector").venv()
									if venv_name ~= nil then
										venv_name = string.gsub(venv_name, ".*/pypoetry/virtualenvs/*", "")
										venv_name = string.gsub(venv_name, ".*/miniconda3/envs/", "")
										venv_name = string.gsub(venv_name, ".*/miniconda3", "base")
									else
										venv_name = "base"
									end
									table.insert(displays, "notebook(" .. venv_name .. ")")
								else
									table.insert(displays, require("internal.lsp").get_display(name))
								end
							end

							return table.concat(displays, " | ")
						end,
					},
					{
						"diagnostics",
						sources = { "nvim_workspace_diagnostic" },
						symbols = { error = " ", warn = " ", hint = "󰌵 " },
						diagnostics_color = {
							color_error = { fg = Colors.red },
							color_warn = { fg = Colors.yellow },
							color_info = { fg = Colors.cyan },
						},
						sections = { "error", "warn", "hint" },
						always_visible = true,
					},
				},
				lualine_y = {
					{
						"tabs",
						mode = 0,
						separators = "",
						cond = function()
							return #vim.api.nvim_list_tabpages() > 1
						end,
						use_mode_colors = true,
						symbols = {
							modified = " " .. Symbols.modified,
						},
					},
				},
				lualine_z = { "progress" },
			},
		})
	end)
plugin("mrjones2014/smart-splits.nvim"):event("VeryLazy"):opts({
	resize_mode = {
		silent = true,
		quit_key = "<ESC>",
	},
})
plugin("rcarriga/nvim-notify")
	:event("VeryLazy")
	:opts({ render = "compact", background_colour = "#000000", stage = "slide" })
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
				"molten_output",
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
	cmdline = {
		view = "cmdline",
	},
	-- add any options here
	presets = {
		bottom_search = true, -- use a classic bottom cmdline for search
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
