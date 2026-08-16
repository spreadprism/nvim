local internal_opencode = require("internal.opencode")

local quick_chat = internal_opencode.quick_chat
local inline_assistant = internal_opencode.inline_assistant

plugin("opencode")
	:dep_on({
		"snacks",
		"blink.cmp",
	})
	:event("DeferredUIEnter")
	:opts({
		preferred_picker = "snacks",
		preferred_completion = "blink",
		default_global_keymaps = false,
		default_mode = "copilot",
		-- `base_context.get_current_cursor_data` reads `context_lines` from this
		-- global config, ignoring the per-call `context_config` — quick_chat's
		-- own `context_lines = 10` and the `#cursor` token's `5` never apply.
		context = {
			cursor_data = {
				enabled = true,
				context_lines = 20,
			},
		},
		ui = {
			input = {
				min_height = 0.15,
			},
		},
		keymap = {
			input_window = {
				["<S-cr>"] = false,
				["<cr>"] = { "submit_input_prompt", mode = { "n", "i" } },
				["<tab>"] = { "switch_mode" },
			},
		},
	})
	:keymaps({
		k:group("opencode", "<localleader>", {
			k:map("n", "m", k:require("opencode.api").configure_provider(), "select model"),
			k:map("n", "a", k:require("opencode.api").select_agent(), "select agent"),
		}):ft("opencode"),
		k
			:group("commit-assistant", "<localleader>a", {
				k:map(
					"n",
					"a",
					quick_chat({
						prompt = "generate the commit message title only, don't ask confirmation just output #git_diff",
						model = "anthropic/claude-sonnet-4-5",
						agent = "gitcommit",
					}),
					"generate title"
				),
				k:map(
					"n",
					"c",
					quick_chat({
						prompt = "generate the commit message title only with @context, don't ask confirmation just output #git_diff",
						model = "anthropic/claude-sonnet-4-5",
						agent = "gitcommit",
					}),
					"generate title with context"
				),
			})
			:ft("gitcommit"),
		k:map("is", "<M-l>", inline_assistant(), "opencode assist"),
		k:group("assistant", "<leader>a", {
			k:map("n", "a", k:require("opencode.api").open_input(), "open"),
			k:map("n", "A", k:require("opencode.api").open_input_new_session(), "open (new session)"),
			k:map("n", "s", k:require("opencode.api").select_session(), "select session"),
			k:map("n", "m", k:require("opencode.api").configure_provider(), "configure model"),
			k:map(
				"nx",
				"p",
				quick_chat({
					model = "anthropic/claude-haiku-4-5",
				}),
				"prompt"
			),
		}),
	})
