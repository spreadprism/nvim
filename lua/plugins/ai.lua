if nixCats("ai") then
	require("internal.lsp").set_client_display("copilot", false)
	plugin("copilot")
		:event_user()
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
		:event_user()
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
		:keys(kgroup("<leader>a", "AI-assistant", {}, {
			kmap("n", "p", kcmd("CodeCompanion"), "Prompt"),
			kmap("v", "p", function()
				vim.ui.input({ prompt = "Prompt" }, function(input)
					vim.cmd("'<,'>CodeCompanion " .. input)
				end)
			end, "Prompt"),
			kmap("v", "e", kcmd("CodeCompanion /explain"), "Explain"),
			kmap("v", "f", kcmd("CodeCompanion @editor /fix"), "Fix"),
			kmap("v", "t", kcmd("CodeCompanion @editor /tests"), "Generate tests"),
			kmap("n", "c", kcmd("CodeCompanionChat Toggle"), "Toggle chat"),
			kmap("n", "a", kcmd("CodeCompanionActions"), "Actions"),
		}))
end
