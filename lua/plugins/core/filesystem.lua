-- plugin("fyler")
-- 	:lazy(false)
-- 	:opts({
-- 		integrations = {
-- 			icon = "nvim_web_devicons",
-- 			winpick = "snacks",
-- 		},
-- 		hooks = {
-- 			on_rename = function(src_path, destination_path)
-- 				require("snacks.rename").on_rename_file(src_path, destination_path)
-- 			end,
-- 		},
-- 		views = {
-- 			finder = {
-- 				columns_order = { "link", "diagnostic", "git", "permission", "size" },
-- 				win = {
-- 					border = "rounded",
-- 				},
-- 				default_explorer = true,
-- 				mappings = {
-- 					["<C-q>"] = "CloseView",
-- 					["<S-CR>"] = "SelectTab",
-- 					["<Left>"] = "CollapseNode",
-- 					["<S-Left>"] = "CollapseAll",
-- 					["_"] = "GotoCwd",
-- 					["-"] = "GotoParent",
-- 					["."] = "GotoNode",
-- 				},
-- 				icon = {
-- 					directory_collapsed = "",
-- 					directory_empty = "",
-- 					directory_expanded = "",
-- 				},
-- 				columns = {
-- 					git = {
-- 						symbols = {
-- 							Added = "+",
-- 							Modified = "~",
-- 							Untracked = "?",
-- 							Ignored = "!",
-- 							Deleted = "-",
-- 							Renamed = "→",
-- 							Conflict = "-",
-- 							PartialStage = "~",
-- 						},
-- 					},
-- 					diagnostic = {
-- 						symbols = {
-- 							Error = symbols.error,
-- 							Warn = symbols.warning,
-- 							Info = symbols.info,
-- 							Hint = symbols.hint,
-- 						},
-- 					},
-- 				},
-- 			},
-- 		},
-- 	})
-- 	:keymaps({
-- 		k:map("n", "-", function()
-- 			local fyler = require("fyler")
-- 			require("fyler.views.finder").instance():change_root(vim.fn.expand("%:p:h"))
-- 			fyler.open()
-- 		end, "open filesystem"),
-- 		k:map("n", "_", function()
-- 			local fyler = require("fyler")
-- 			require("fyler.views.finder").instance():change_root(vim.fn.getcwd())
-- 			fyler.open()
-- 		end, "open filesystem"),
-- 	})

local oil = plugin("oil")
	:opts({
		use_default_keymaps = false,
		experimental_watch_for_changes = true,
		skip_confirm_for_simple_edits = true,
		keymaps = {
			["g?"] = "actions.show_help",
			["<CR>"] = "actions.select",
			["<S-CR>"] = "actions.select_tab",
			["<M-CR>"] = "actions.select_vsplit",
			["K"] = "actions.preview",
			["-"] = "actions.parent",
			["<C-q>"] = "actions.close",
			["_"] = "actions.open_cwd",
			["."] = "actions.cd",
		},
		view_options = {
			show_hidden = true,
			natural_order = false,
		},
		win_options = {
			signcolumn = "number",
		},
		confirmation = {
			border = "rounded",
		},
	})
	:keymaps({
		k:map("n", "-", k:cmd("Oil"), "Open filesystem"),
		k:map("n", "_", function()
			vim.cmd("Oil " .. vim.fn.getcwd())
		end, "Open current working directory"),
	})
	:on_highlights(function(highlights, _)
		highlights.OilDirHidden = "OilDir"
		highlights.OilFileHidden = "OilFile"
	end)
	:lazy(false)

plugin("oil-git"):dep_on(oil):lazy(false):opts({
	show_directory_symbols = false,
	show_ignored_files = true,
	show_ignored_directories = false,
	symbols = {
		file = {
			added = "+",
			modified = "~",
			untracked = "?",
			ignored = "!",
			deleted = "-",
			renamed = "→",
			conflict = "!",
		},
	},
	highlights = {
		OilGitAdded = { fg = "#9ece6a" },
		OilGitModified = { fg = "#e0af68" },
		OilGitRenamed = { fg = "#cba6f7" },
		OilGitUntracked = { fg = "#7aa2f7" },
		OilGitIgnored = { fg = "#565F89" },
		OilGitDeleted = { fg = "#f7768e" },
		OilGitConflict = { fg = "#f7768e" },
	},
})
