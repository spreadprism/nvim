plugin("tabout"):event({ "InsertEnter", "CmdlineEnter" }):opts({
	act_as_shift_tab = true,
	tabouts = {
		{ open = "'", close = "'" },
		{ open = '"', close = '"' },
		{ open = "`", close = "`" },
		{ open = "(", close = ")" },
		{ open = "[", close = "]" },
		{ open = "{", close = "}" },
		{ open = "<", close = ">" },
	},
})
local BEFORE, AFTER = 1, 2
plugin("hop")
	:event("DeferredUIEnter")
	:keymaps({
		k:map("nx", "<M-w>", k:require("hop").hint_words(), "hop to word"),
		k:map("nx", "<M-w>", k:require("hop").hint_lines(), "hop to line"):ft("oil"),
		k:map("nx", "f", k:require("hop").hint_char1({ current_line_only = true, direction = AFTER }), "hop to char"),
		k:map("nx", "F", k:require("hop").hint_char1({ current_line_only = true, direction = BEFORE }), "hop to char"),
		k:map(
			"nx",
			"t",
			k:require("hop").hint_char1({ current_line_only = true, direction = AFTER, hint_offset = -1 }),
			"hop before char"
		),
		k:map(
			"nx",
			"T",
			k:require("hop").hint_char1({ current_line_only = true, direction = BEFORE, hint_offset = 1 }),
			"hop before char"
		),
	})
	:on_highlights(function(highlights, colors)
		highlights.HopNextKey = { fg = colors.orange, bold = true, underline = true }
		highlights.HopNextKey1 = { fg = colors.orange, bold = true, underline = true }
		highlights.HopNextKey2 = { fg = colors.orange, bold = true }
	end)

-- TODO: harpoon or alternatives (with row marks)
