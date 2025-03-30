if nixCats("ai") then
	plugin("copilot")
		:triggerUIEnter()
		:on_require("copilot")
		:opts({
			suggestion = {
				enabled = true,
				auto_trigger = false,
				keymap = {
					accept = "<M-a>",
					dismiss = "<M-d>",
					next = false,
				},
			},
			panel = { enabled = false },
		})
		:on_plugin("codecompanion.nvim")
	local GetChatAdapter = function()
		if os.getenv("GEMINI_API_KEY") ~= nil then
			return "gemini"
		else
			return "copilot"
		end
	end
	plugin("codecompanion.nvim")
		:triggerUIEnter()
		:on_require("codecompanion")
		:opts({
			display = {
				diff = {
					provider = "mini_diff",
				},
				chat = {
					window = {
						layout = "float",
						border = "rounded",
						height = 0.8,
						width = 0.8,
					},
				},
			},
			strategies = {
				chat = {
					adapter = GetChatAdapter(),
					keymaps = {
						close = {
							modes = { i = "<C-q>" },
						},
					},
				},
				inline = {
					adapter = GetChatAdapter(),
				},
			},
		})
		:keys(keymapGroup("<leader>a", "AI-assistant", {
			keymap("n", "p", keymapCmd("CodeCompanion"), "Prompt"),
			keymap("v", "p", function()
				vim.ui.input({ prompt = "Prompt" }, function(input)
					vim.cmd("'<,'>CodeCompanion " .. input)
				end)
			end, "Prompt"),
			keymap("v", "e", keymapCmd("CodeCompanion /explain"), "Explain"),
			keymap("v", "f", keymapCmd("CodeCompanion @editor /fix"), "Fix"),
			keymap("v", "t", keymapCmd("CodeCompanion @editor /tests"), "Generate tests"),
			keymap("n", "c", keymapCmd("CodeCompanionChat Toggle"), "Toggle chat"),
			keymap("n", "a", keymapCmd("CodeCompanionActions"), "Actions"),
		}))
end
