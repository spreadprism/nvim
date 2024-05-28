local main_hop_f = function()
	local current_oil_dir = require("oil").get_current_dir()
	if current_oil_dir == nil then
		vim.cmd("HopWord")
	else
		vim.cmd("HopLine")
	end
end

local hop = require("hop")
keybind("n", "F", main_hop_f, "Jump to word"):register()
keybind("v", "F", "<cmd>HopLine<cr>", "Jump to line"):register()
keybind("n", "gl", "<cmd>HopLine<cr>", "Jump to line"):register()
keybind({ "n", "v" }, "gf", "<cmd>HopChar1<cr>", "Global jump to char"):register()
keybind({ "n", "v" }, "f", function()
	hop.hint_char1({ current_line_only = true })
end, "Jump to char"):register()
keybind({ "n", "v" }, "t", function()
	hop.hint_char1({ current_line_only = true, hint_offset = -1 })
end, "Jump before char"):register()
