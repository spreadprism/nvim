local hop = require("internal.hop")
plugin("hop.nvim")
	:event_user()
	:on_require("hop")
	:keys({
		kmap({ "n", "v" }, "<M-s>", hop.hop_word, "hop"),
		kmap({ "n", "v" }, "<M-S>", hop.hop_char_global, "jump char"),
		kmap({ "n", "v" }, "f", hop.hop_char_line(), "hop char l-AC"),
		kmap({ "n", "v" }, "F", hop.hop_char_line(false), "hop char l-BC"),
		kmap({ "n", "v" }, "t", hop.hop_char_line(true, -1), "hop before char l-AC"),
		kmap({ "n", "v" }, "T", hop.hop_char_line(false, 1), "hop after char l-BC"),
		kmap("v", "<M-l>", kcmd("HopLine"), "hop line"),
		kmap("n", "<M-l>", kcmd("HopLineStart"), "hop line start"),
		kmap("n", "<M-/>", kcmd("HopPattern"), "hop at pattern"),
	})
	:setup(function()
		---@diagnostic disable-next-line: deprecated
		local fg = vim.api.nvim_get_hl_by_name("Constant", true).foreground
		vim.api.nvim_set_hl(0, "HopNextKey", { fg = fg, bold = true, underline = true })
		vim.api.nvim_set_hl(0, "HopNextKey1", { fg = fg, bold = true, underline = true })
		vim.api.nvim_set_hl(0, "HopNextKey2", { fg = fg, bold = true })
	end)
plugin("harpoon"):event_user():config(false):keys({
	kmap("n", "<M-m>", function()
		require("harpoon"):list():add()
	end, "mark"),
	kmap("n", "<M-u>", function()
		require("harpoon"):list():remove()
	end, "unmark"),
	kmap("n", "<M-h>", function()
		require("harpoon").ui:toggle_quick_menu(require("harpoon"):list(), { border = "rounded" })
	end, "harpoon list"),
	kmap("n", "<M-i>", function()
		require("harpoon"):list():next({ ui_nav_wrap = true })
	end, "next mark"),
	kmap("n", "<M-o>", function()
		require("harpoon"):list():prev({ ui_nav_wrap = true })
	end, "previous mark"),
})
