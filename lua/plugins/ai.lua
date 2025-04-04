if nixCats("ai") then
	require("internal.lsp").set_client_display("copilot", false)
	plugin("copilot")
		:event_defer()
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
	local code_adapter = "copilot"
	if os.getenv("GEMINI_API_KEY") ~= nil then
		code_adapter = "gemini"
	end
	plugin("codecompanion.nvim")
		:event_defer()
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
					adapter = code_adapter,
					keymaps = {
						close = {
							modes = { i = "<C-q>" },
						},
					},
				},
				inline = {
					adapter = code_adapter,
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
		:setup(function()
			-- vim.api.nvim_create_autocmd("BufLeave", {
			-- 	pattern = "*[CodeCompanion]*",
			-- 	callback = function()
			-- 		vim.cmd("CodeCompanionChat Toggle")
			-- 	end,
			-- })
		end)
end
