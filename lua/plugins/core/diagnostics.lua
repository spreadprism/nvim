plugin("trouble.nvim")
	:on_require("trouble")
	:cmd("Trouble")
	:opts({
		auto_preview = false,
		focus = true,
	})
	:keys({
		keymap("n", "<M-t>", keymapCmd("Trouble diagnostics toggle")),
		keymap("n", "<M-T>", keymapCmd("Trouble diagnostics toggle filter.buf=0")),
		keymap("n", "<M-d>", function()
			vim.diagnostic.open_float({
				border = "rounded",
				scope = "line",
				prefix = function(_, i, total)
					if total == 1 then
						return "", ""
					end
					return "(" .. i .. "/" .. total .. ") ", ""
				end,
			})
		end),
	})
