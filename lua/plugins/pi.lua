local ft = {
	"pi-chat-prompt",
	"pi-chat-history",
}

vim.treesitter.language.register("markdown", "pi-chat-prompt")
vim.treesitter.language.register("markdown", "pi-chat-history")

plugin("pi")
	:event("DeferredUIEnter")
	:opts({
		layout = {
			side = {
				width = 70,
				panels = {
					prompt = { winbar = false },
				},
			},
		},
		panels = {
			prompt = { title = "" },
		},
		statusline = {
			layout = {
				left = { "tokens", " ", "cost", " ", "context" },
				right = { "model", " ", "thinking" },
			},
		},
		zen = {
			keys = {
				toggle = "<M-p>",
			},
		},
	})
	:keymaps({
		k:map("nx", "<M-p>", function()
			local pi = require("pi")
			if pi.is_visible() then
				pi.send_mention(nil, { focus = false })
			else
				pi.show()
			end
		end, "open PI"),
		k:map("ni", "<C-q>", k:cmd("Pi"), "close PI"):ft(ft),
		k:map("ni", "<C-c>", k:cmd("PiAbort"), "abort"):ft(ft),
	})
	:on_highlights(function(highlights, colors)
		highlights.PiMention = { fg = colors.blue }
		highlights.PiCommand = highlights.PiMention
	end)
