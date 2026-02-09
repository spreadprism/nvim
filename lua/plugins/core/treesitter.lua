plugin("nvim-treesitter-endwise"):on_plugin("nvim-treesitter"):opts(false)
plugin("nvim-treesitter"):event("DeferredUIEnter"):opts(false):after(function()
	require("nvim-treesitter.configs").setup({
		highlight = { enable = true },
		indent = {
			enable = true,
			disable = { "nix" },
		},
		endwise = {
			enable = true,
		},
	})
end)

local select = k:require("nvim-treesitter-textobjects.select").select_textobject

local swap_next = k:require("nvim-treesitter-textobjects.swap").swap_next
local swap_prev = k:require("nvim-treesitter-textobjects.swap").swap_previous

local goto_next_start = k:require("nvim-treesitter-textobjects.move").goto_next_start
local goto_prev_start = k:require("nvim-treesitter-textobjects.move").goto_previous_start

local rlm_next = k:require("nvim-treesitter-textobjects.repeatable_move").repeat_last_move_next
local rlm_prev = k:require("nvim-treesitter-textobjects.repeatable_move").repeat_last_move_previous

plugin("nvim-treesitter-textobjects")
	:on_plugin("nvim-treesitter")
	:opts({
		select = {
			lookahead = true,
			selection_modes = {
				["@assignment.outer"] = "V", -- linewise
			},
		},
	})
	:keymaps({
		-- INFO: SELECT
		-- assignement
		k:map("xo", "aa", select("@assignment.outer", "textobjects"), "assignment"),
		k:map("xo", "ia", select("@assignment.inner", "textobjects"), "assignment"),
		-- function
		k:map("xo", "af", select("@function.outer", "textobjects"), "function"),
		k:map("xo", "if", select("@function.inner", "textobjects"), "function"),
		-- loop
		k:map("xo", "al", select("@loop.outer", "textobjects"), "loop"),
		k:map("xo", "il", select("@loop.inner", "textobjects"), "loop"),
		-- conditional
		k:map("xo", "ai", select("@conditional.outer", "textobjects"), "conditional"),
		k:map("xo", "ii", select("@conditional.inner", "textobjects"), "conditional"),
		-- class
		k:map("xo", "ac", select("@class.outer", "textobjects"), "class"),
		k:map("xo", "ic", select("@class.inner", "textobjects"), "class"),
		-- return
		k:map("xo", "ar", select("@return.outer", "textobjects"), "return"),
		k:map("xo", "ir", select("@return.inner", "textobjects"), "return"),
		-- parameter
		k:map("xo", "ap", select("@parameter.outer", "textobjects"), "parameter"),
		k:map("xo", "ip", select("@parameter.inner", "textobjects"), "parameter"),
		-- INFO: SWAP
		-- parameter
		k:map("n", "<M-Right>", swap_next("@parameter.inner", "textobjects"), "swap next parameter"),
		k:map("n", "<M-Left>", swap_prev("@parameter.inner", "textobjects"), "swap previous parameter"),
		-- INFO: MOVE
		-- parameter
		k:map("nxo", "]p", goto_next_start("@parameter.inner", "textobjects", true), "next parameter"),
		k:map("nxo", "[p", goto_prev_start("@parameter.inner", "textobjects", true), "previous parameter"),
		-- repeat
		k:map("nxo", ";", rlm_next(), "repeat last move next"),
		k:map("nxo", ",", rlm_prev(), "repeat last move previous"),
	})
-- TODO: treesitter-context
