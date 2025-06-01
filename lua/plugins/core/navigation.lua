local hop = require("internal.hop")
plugin("hop.nvim")
	:event_defer()
	:on_require("hop")
	:keys({
		kmap({ "n", "x" }, "<M-s>", hop.hop_word, "hop"),
		kmap({ "n", "x" }, "<M-S>", hop.hop_char_global, "jump char"),
		kmap({ "n", "x" }, "f", hop.hop_char_line(), "hop char l-AC"),
		kmap({ "n", "x" }, "F", hop.hop_char_line(false), "hop char l-BC"),
		kmap({ "n", "x" }, "t", hop.hop_char_line(true, -1), "hop before char l-AC"),
		kmap({ "n", "x" }, "T", hop.hop_char_line(false, 1), "hop after char l-BC"),
		kmap("v", "<M-;>", kcmd("HopLine"), "hop line"),
		kmap("n", "<M-;>", kcmd("HopLineStart"), "hop line start"),
		kmap("n", "<M-/>", kcmd("HopPattern"), "hop at pattern"),
	})
	:setup(function()
		---@diagnostic disable-next-line: deprecated
		local fg = vim.api.nvim_get_hl_by_name("Constant", true).foreground
		vim.api.nvim_set_hl(0, "HopNextKey", { fg = fg, bold = true, underline = true })
		vim.api.nvim_set_hl(0, "HopNextKey1", { fg = fg, bold = true, underline = true })
		vim.api.nvim_set_hl(0, "HopNextKey2", { fg = fg, bold = true })
	end)

plugin("flash.nvim")
	:event_defer()
	:opts({
		modes = {
			char = {
				enabled = false,
			},
			treesitter = {
				highlight = {
					backdrop = true,
				},
			},
		},
	})
	:keys({
		kmap("v", "v", function()
			require("flash").treesitter()
		end, "treesitter"),
		kmap("v", "<M-s>", function()
			require("flash").treesitter_search()
		end, "treesitter search"),
	})
	:setup(function()
		---@diagnostic disable-next-line: deprecated
		local fg = vim.api.nvim_get_hl_by_name("Constant", true).foreground
		vim.api.nvim_set_hl(0, "FlashLabel", { fg = fg, bold = true, underline = true })
	end)
plugin("harpoon"):event_defer():config(false):keys({
	kmap("n", "<M-m>", function()
		require("harpoon"):list():add()
	end, "mark"),
	kmap("n", "<M-M>", function()
		require("harpoon"):list():remove()
	end, "unmark"),
	kmap("n", "<M-e>", function()
		require("harpoon").ui:toggle_quick_menu(require("harpoon"):list(), { border = "rounded" })
	end, "harpoon list"),
	kmap("n", "<M-1>", function()
		require("harpoon"):list():select(1)
	end, "go to harpoon mark(1)"),
	kmap("n", "<M-2>", function()
		require("harpoon"):list():select(2)
	end, "go to harpoon mark(2)"),
	kmap("n", "<M-3>", function()
		require("harpoon"):list():select(3)
	end, "go to harpoon mark(3)"),
	kmap("n", "<M-4>", function()
		require("harpoon"):list():select(4)
	end, "go to harpoon mark(4)"),
	kmap("n", "<M-5>", function()
		require("harpoon"):list():select(5)
	end, "go to harpoon mark(5)"),
	kmap("n", "<M-6>", function()
		require("harpoon"):list():select(6)
	end, "go to harpoon mark(6)"),
	kmap("n", "<M-7>", function()
		require("harpoon"):list():select(7)
	end, "go to harpoon mark(7)"),
	kmap("n", "<M-8>", function()
		require("harpoon"):list():select(8)
	end, "go to harpoon mark(8)"),
	kmap("n", "<M-9>", function()
		require("harpoon"):list():select(9)
	end, "go to harpoon mark(9)"),
})
