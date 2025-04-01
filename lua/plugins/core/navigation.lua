local hop = require("internal.hop")
plugin("hop.nvim")
	:triggerBufferEnter()
	:on_require("hop")
	:keys({
		keymap({ "n", "v" }, "<M-s>", hop.hop_word, "hop"),
		keymap({ "n", "v" }, "<M-S>", hop.hop_char_global, "jump char"),
		keymap({ "n", "v" }, "f", hop.hop_char_line(), "hop char l-AC"),
		keymap({ "n", "v" }, "F", hop.hop_char_line(false), "hop char l-BC"),
		keymap({ "n", "v" }, "t", hop.hop_char_line(true, -1), "hop before char l-AC"),
		keymap({ "n", "v" }, "T", hop.hop_char_line(false, 1), "hop after char l-BC"),
		keymap("v", "<M-l>", keymapCmd("HopLine"), "hop line"),
		keymap("n", "<M-l>", keymapCmd("HopLineStart"), "hop line start"),
		keymap("n", "<M-/>", keymapCmd("HopPattern"), "hop at pattern"),
	})
	:after(function()
		require("hop").setup({})
		---@diagnostic disable-next-line: deprecated
		local fg = vim.api.nvim_get_hl_by_name("Constant", true).foreground
		vim.api.nvim_set_hl(0, "HopNextKey", { fg = fg, bold = true, underline = true })
		vim.api.nvim_set_hl(0, "HopNextKey1", { fg = fg, bold = true, underline = true })
		vim.api.nvim_set_hl(0, "HopNextKey2", { fg = fg, bold = true })
	end)
plugin("harpoon"):triggerUIEnter():after(nil):keys({
	keymap("n", "<M-m>", function()
		require("harpoon"):list():add()
	end, "mark"),
	keymap("n", "<M-u>", function()
		require("harpoon"):list():remove()
	end, "unmark"),
	keymap("n", "<M-h>", function()
		require("harpoon").ui:toggle_quick_menu(require("harpoon"):list(), { border = "rounded" })
	end, "harpoon list"),
	keymap("n", "<M-i>", function()
		require("harpoon"):list():next({ ui_nav_wrap = true })
	end, "next mark"),
	keymap("n", "<M-o>", function()
		require("harpoon"):list():prev({ ui_nav_wrap = true })
	end, "previous mark"),
})
