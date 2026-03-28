plugin("copilot")
	:event("DeferredUIEnter")
	:opts({
		filetypes = {
			markdown = true,
			yaml = true,
		},
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
	:after(function()
		require("internal.loader.lsp").display_blacklist("copilot")
	end)

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
		ui = {
			input = {
				min_height = 0.15,
			},
		},
		keymap = {
			input_window = {
				["<S-cr>"] = false,
				["<cr>"] = { "submit_input_prompt", mode = { "n", "i" } },
			},
		},
	})
	:keymaps({
		k:group("assistant", "<leader>a", {
			k:map("n", "a", k:require("opencode.api").open_input(), "open"),
			k:map("n", "A", k:require("opencode.api").open_input_new_session(), "open (new session)"),
			k:map("nv", "p", k:require("opencode.api").quick_chat(), "prompt"),
			k:map("n", "s", k:require("opencode.api").select_session(), "select session"),
			k:map("n", "m", k:require("opencode.api").configure_provider(), "configure model"),
		}),
	})
