plugin("copilot")
	:event("DeferredUIEnter")
	:opts({
		filetypes = {
			markdown = true,
			yaml = true,
			gitcommit = true,
		},
		suggestion = {
			enabled = true,
			auto_trigger = false,
			keymap = {
				accept = false,
				dismiss = "<M-d>",
				next = false,
			},
		},
		panel = { enabled = false },
		should_attach = function(buf_id, bufname)
			if vim.bo[buf_id].buftype ~= "" then
				return false
			end

			return true
		end,
		server = {
			type = "binary",
			custom_server_filepath = nixCats("overlays")["copilot-language-server"].path,
		},
	})
	:after(function()
		require("internal.loader.lsp").display_blacklist("copilot")
	end)

--- Quick chat with per-invocation `model`/`agent` overrides.
---
--- `opencode.api.quick_chat` routes through `workflow.actions.quick_chat`,
--- which hardcodes the opts it forwards (`{ context_config = ctx }`), dropping
--- everything else. The underlying `opencode.quick_chat.quick_chat(prompt,
--- opts, range)` does accept `{ context_config, model, agent }` and resolves
--- the model at call time (`opts.model or config.quick_chat.default_model or
--- current_model`), so this replicates the workflow handler and forwards ours.
--- A `prompt` skips the input box and sends immediately. Prompts may embed
--- context tokens (`#git_diff`, `#buffer`, ...), which `parse_quick_context_args`
--- strips out and turns into the request's context config.
---@param opts? { prompt?: string, model?: string, agent?: string|fun():string? }
local function quick_chat(opts)
	return function()
		local util = require("opencode.util")

		local range
		if vim.fn.mode():match("[vV\022]") then
			local visual = util.get_visual_range()
			range = visual and { start = visual.start_line, stop = visual.end_line } or nil
		end

		-- Resolve now, not in the callback: `vim.ui.input` defers, by which
		-- point the current buffer/filetype is the input window's.
		local resolved = vim.tbl_extend("force", {}, opts or {})
		local preset = resolved.prompt
		resolved.prompt = nil
		if type(resolved.agent) == "function" then
			resolved.agent = resolved.agent()
		end

		local function send(input)
			if not input or input == "" then
				return
			end
			local prompt, ctx = util.parse_quick_context_args(input)
			resolved.context_config = ctx
			require("opencode.quick_chat").quick_chat(prompt, resolved, range)
		end

		if preset then
			return send(preset)
		end

		vim.ui.input({ prompt = "Quick Chat Message: ", win = { relative = "cursor" } }, send)
	end
end

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
		k:group("commit-assistant", "<localleader>a", {
			k:map(
				"n",
				"a",
				quick_chat({
					prompt = "generate the commit message title only, don't ask confirmation just output #git_diff",
					model = "anthropic/claude-haiku-4-5",
					agent = "gitcommit",
				}),
				"generate title"
			),
		}):ft("gitcommit"),
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
