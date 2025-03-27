plugin("blink.cmp"):event({ "InsertEnter", "CmdlineEnter" }):opts({
	keymap = {
		preset = "none",
		["<M-a>"] = { "select_and_accept", "fallback" },
		["<M-j>"] = { "select_next", "fallback" },
		["<M-k>"] = { "select_prev" },
		["<M-x>"] = { "cancel" },
		["<M-l>"] = {
			function(cmp)
				if cmp.visible() then
					cmp.close()
				end
				require("copilot.suggestion").next()
			end,
		},
		["<M-h>"] = {
			function(cmp)
				if cmp.is_visible() then
					cmp.hide()
				else
					cmp.show()
				end
			end,
		},
	},
	completion = {
		menu = {
			border = "rounded",
			auto_show = true,
		},
	},
	cmdline = {
		keymap = {
			["<M-a>"] = { "select_and_accept", "fallback" },
			["<M-j>"] = { "show", "select_next", "fallback" },
			["<M-k>"] = { "show", "select_prev" },
			["<M-x>"] = { "cancel" },
			["<M-h>"] = {
				function(cmp)
					if cmp.is_visible() then
						cmp.hide()
					else
						cmp.show()
					end
				end,
			},
		},
		completion = {
			menu = {
				auto_show = false,
			},
		},
	},
})
