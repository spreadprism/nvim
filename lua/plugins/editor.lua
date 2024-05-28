local treesitter = plugin("nvim-treesitter/nvim-treesitter"):event("BufRead")
plugin("christoomey/vim-tmux-navigator"):event("VeryLazy")
plugin("smoka7/hop.nvim"):event("VeryLazy"):opts({})
plugin("altermo/ultimate-autopair.nvim"):event({ "InsertEnter", "CmdlineEnter" }):opts({})
plugin("RRethy/nvim-treesitter-endwise"):dependencies(treesitter):event("VeryLazy")
plugin("kylechui/nvim-surround"):event("VeryLazy"):opts({})
plugin("abecodes/tabout.nvim"):dependencies({ "hrsh7th/nvim-cmp", treesitter }):event("InsertCharPre"):opts({})
plugin("echasnovski/mini.surround"):event("VeryLazy"):opts({
	mappings = {
		delete = "",
		find = "",
		find_left = "",
		highlight = "",
		replace = "",
		update_n_lines = "",
		suffix_last = "",
		suffix_next = "",
	},
})
plugin("echasnovski/mini.move"):event("VeryLazy"):opts({
	mappings = {
		up = "<M-k>",
		down = "<M-j>",
		right = "",
		left = "",
		line_left = "",
		line_right = "",
		line_down = "<M-j>",
		line_up = "<M-k>",
	},
})
plugin("mrjones2014/smart-splits.nvim"):event("VeryLazy"):opts({
	resize_mode = {
		silent = true,
		quit_key = "<M-r>",
	},
})
plugin("mfussenegger/nvim-lint"):event("VeryLazy"):config("configs.linting")
plugin("mhartington/formatter.nvim"):event("VeryLazy"):config("configs.formatting")
plugin("numToStr/Comment.nvim"):event("VeryLazy"):opts({})
