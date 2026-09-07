-- TODO: add https://github.com/HakonHarnes/img-clip.nvim
local internal = require("internal.pi")
local ft = internal.ft.keymap

internal.ft.register_treesitter()

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
				pi.send_mention(internal.oil_mention(), { focus = false })
			else
				vim.cmd("Pi")
			end
		end, "open PI"),
		k:map("ni", "<C-q>", k:cmd("Pi"), "close PI"):ft(ft),
		k:map("ni", "<C-c>", k:cmd("PiAbort"), "abort"):ft(ft),
		-- buffer local
		k:map("ni", "<M-b>", function()
			local mention = internal.last_buffer_mention()
			if not mention then
				vim.notify("no buffer to mention", vim.log.levels.WARN)
				return
			end
			require("pi").send_mention(mention)
		end, "mention last buffer"):ft(ft),
		k:map("ni", "<localleader>s", k:require("pi").resume_session(), "session"):ft(ft),
		k:map("ni", "<localleader>x", k:require("pi").new_session(), "new session"):ft(ft),
		k:map("ni", "<localleader>m", k:require("pi").select_model(), "select model"):ft(ft),
		k:map("ni", "<localleader>t", k:require("pi").toggle_thinking(), "toggle thinking"):ft(ft),
	})
	:after(function()
		internal.register_tool_renderers()
		internal.track_last_buffer()
		internal.close_when_last()
	end)
	:on_highlights(function(highlights, colors)
		-- chat history
		highlights.PiUserMessageLabel = { fg = colors.blue, bold = true }
		highlights.PiAgentResponseLabel = { fg = colors.magenta, bold = true }
		highlights.PiDebugLabel = { fg = colors.dark5, bold = true }
		highlights.PiStartupLabel = { fg = colors.teal, bold = true }
		highlights.PiStartupErrorLabel = { fg = colors.red1, bold = true }
		highlights.PiStartupHint = { fg = colors.comment, italic = true }
		highlights.PiStartupDetail = { fg = colors.fg_dark }
		highlights.PiStartupError = { fg = colors.red1 }
		highlights.PiCompactionLabel = { fg = colors.orange, bold = true }
		highlights.PiCompactionText = { fg = colors.fg_dark }
		highlights.PiCompactionHint = { fg = colors.comment, italic = true }
		highlights.PiMessageDateTime = { fg = colors.dark3, italic = true }
		highlights.PiMessageQueueTag = { fg = colors.yellow, italic = true }
		highlights.PiMessageAttachments = { fg = colors.cyan }
		highlights.PiPendingQueueLabel = { fg = colors.yellow, bold = true }
		highlights.PiPendingQueueText = { fg = colors.fg_dark, italic = true }
		highlights.PiThinking = { fg = colors.comment, italic = true }
		highlights.PiMention = { fg = colors.blue }
		highlights.PiCommand = highlights.PiMention
		highlights.PiWelcome = { fg = colors.magenta, bold = true }
		highlights.PiWelcomeHint = { fg = colors.comment, italic = true }
		highlights.PiBusy = { fg = colors.purple, italic = true }
		highlights.PiBusyTime = { fg = colors.dark3 }
		highlights.PiWarning = { fg = colors.warning }
		highlights.PiError = { fg = colors.error }
		highlights.PiDebug = { fg = colors.dark5 }

		-- tool blocks
		highlights.PiToolBorder = { fg = colors.fg_gutter }
		highlights.PiToolHeader = { fg = colors.cyan, bold = true }
		highlights.PiToolCall = { fg = colors.fg_dark }
		highlights.PiToolOutput = { fg = colors.comment }
		highlights.PiToolStatus = { fg = colors.green1, italic = true }
		highlights.PiToolCollapsed = { fg = colors.dark3, italic = true }
		highlights.PiToolError = { fg = colors.red }
		highlights.PiTableBorder = { fg = colors.fg_gutter }
		highlights.PiTableHeader = { fg = colors.blue, bold = true }
		highlights.PiDiffAdd = { fg = colors.git.add, bg = colors.diff.add }
		highlights.PiDiffDelete = { fg = colors.git.delete, bg = colors.diff.delete }
		highlights.PiDiffLineNr = { fg = colors.dark3 }

		-- attachments
		highlights.PiAttachmentIcon = { fg = colors.green1 }
		highlights.PiAttachmentFilename = { fg = colors.fg_dark }

		-- panels and layout
		highlights.PiFloat = { fg = colors.fg, bg = colors.none }
		highlights.PiFloatBorder = { fg = colors.border_highlight, bg = colors.none }
		highlights.PiChatHistoryWinbar = { bg = colors.none }
		highlights.PiChatHistoryWinbarTitle = { fg = colors.magenta, bold = true, bg = colors.none }
		highlights.PiChatPromptWinbar = { bg = colors.none }
		highlights.PiChatPromptWinbarTitle = { fg = colors.blue, bold = true, bg = colors.none }
		highlights.PiChatPromptWinbarAttentionTitle = { fg = colors.orange, bold = true, bg = colors.none }
		highlights.PiChatAttachmentsWinbar = { bg = colors.none }
		highlights.PiChatAttachmentsWinbarTitle = { fg = colors.green1, bold = true, bg = colors.none }
		highlights.PiChatHistoryFloatTitle = { fg = colors.magenta, bold = true }
		highlights.PiChatPromptFloatTitle = { fg = colors.blue, bold = true }
		highlights.PiChatPromptFloatAttentionTitle = { fg = colors.orange, bold = true }
		highlights.PiChatAttachmentsFloatTitle = { fg = colors.green1, bold = true }

		-- zen mode
		highlights.PiZen = { fg = colors.fg, bg = colors.bg_dark1 }
		highlights.PiZenBackdrop = { bg = colors.bg }

		-- dialogs
		highlights.PiDialogTitle = { fg = colors.purple, bold = true }
		highlights.PiDialogSelected = { bg = colors.bg_visual, bold = true }

		-- diff review
		highlights.PiDiffWinbar = { bg = colors.none }
		highlights.PiDiffWinbarCurrent = { fg = colors.red, bold = true, bg = colors.none }
		highlights.PiDiffWinbarProposed = { fg = colors.green, bold = true, bg = colors.none }
		highlights.PiDiffWinbarHint = { fg = colors.comment, italic = true, bg = colors.none }
		highlights.PiDiffReviewNote = { fg = colors.yellow, italic = true }

		-- statusline
		highlights.PiStatusLine = { fg = colors.blue, bg = colors.none }
		highlights.PiStatusLineAttention = { fg = colors.orange, bold = true, bg = colors.none }
		highlights.PiStatusLineWarning = { fg = colors.warning, bg = colors.none }
		highlights.PiStatusLineError = { fg = colors.error, bold = true, bg = colors.none }
	end)
