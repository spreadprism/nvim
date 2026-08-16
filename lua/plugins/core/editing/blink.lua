plugin("blink.indent")
	:event("BufEnter")
	:on_highlights(function(highlights, colors)
		highlights.BlinkIndentScope = { fg = colors.comment }
	end)
	:opts({
		blocked = {
			filetypes = {
				include_defaults = true,
				"fyler",
			},
		},
		mappings = {
			object_scope = "",
			object_scope_with_border = "",
		},
		static = {
			enabled = false,
		},
		scope = {
			char = "¦",
			highlights = { "BlinkIndentScope" },
		},
	})
plugin("blink.pairs"):event("DeferredUIEnter"):opts({
	highlights = {
		enabled = false,
	},
})
plugin("blink.cmp")
	:event({ "InsertEnter", "CmdlineEnter" })
	:dep_on({
		plugin("blink-compat"):on_require("blink.compat"),
		plugin("blink-cmp-git"):opts(false),
		plugin("blink-cmp-conventional-commits"):opts(false),
	})
	:opts(function()
		local cmp_kinds = {
			Text = "",
			Method = "",
			Function = "",
			Constructor = "",
			Field = "",
			Variable = "",
			Class = "",
			Interface = "",
			Module = "",
			Property = "",
			Unit = "",
			Value = "",
			Enum = "",
			Keyword = "",
			Snippet = "",
			Color = "",
			File = "",
			Reference = "",
			Folder = "",
			EnumMember = "",
			Constant = "",
			Struct = "",
			Event = "",
			Operator = "",
			TypeParameter = "",
			Copilot = "",
		}
		local base_keymap = {
			["<M-a>"] = {
				function(cmp)
					if cmp.is_visible() then
						cmp.select_and_accept()
					end
				end,
			},
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
		}
		local default = {
			"snippets",
			"lsp",
			"path",
			"buffer",
			"git",
			"conventional_commits",
		}
		-- Snippets are penalised by default (score_offset -1 vs 0 for lsp), so the
		-- `func` keyword outranks the `func` snippet. Prefer the snippet, but only
		-- against LSP `Keyword` items: every other LSP item keeps default ranking.
		-- Returning nil falls through to the next sort.
		local keyword_kind = vim.lsp.protocol.CompletionItemKind.Keyword
		local function snippets_over_keywords(a, b)
			if a.source_id == "snippets" and b.kind == keyword_kind then
				return true
			end
			if b.source_id == "snippets" and a.kind == keyword_kind then
				return false
			end
		end

		-- On a choiceNode, <M-s> opens the vim.ui.select choice picker; otherwise
		-- it falls through to the signature help below. Returning false continues
		-- to the next command in the list.
		local function select_choice()
			local ok, ls = pcall(require, "luasnip")
			if not ok or not ls.choice_active() then
				return false
			end
			require("luasnip.extras.select_choice")()
			return true
		end

		-- With the menu open, <M-s> takes the first snippet in the list. Prefers
		-- the snippets provider and falls back to any Snippet-kind item, since
		-- LSP servers hand those out too. Returning false continues the chain.
		local function accept_first_snippet(cmp)
			if not cmp.is_visible() then
				return false
			end
			local blink = require("blink.cmp")
			if type(blink.get_items) ~= "function" then
				return false
			end
			local got, items = pcall(blink.get_items)
			if not got or type(items) ~= "table" then
				return false
			end

			local snippet_kind = vim.lsp.protocol.CompletionItemKind.Snippet
			local by_kind
			for idx, item in ipairs(items) do
				if item.source_id == "snippets" then
					cmp.accept({ index = idx })
					return true
				end
				if not by_kind and item.kind == snippet_kind then
					by_kind = idx
				end
			end
			if by_kind then
				cmp.accept({ index = by_kind })
				return true
			end
			return false
		end

		---@type blink.cmp.Config
		return {
			snippets = { preset = "luasnip" },
			fuzzy = {
				sorts = { snippets_over_keywords, "score", "sort_text" },
			},
			sources = {
				default = default,
				per_filetype = {
					oil = { "path", "buffer", "snippets" },
					-- sql = vim.tbl_extend("force", default, { "dbab" }),
				},
				providers = {
					lazydev = {
						name = "LazyDev",
						enabled = function()
							return vim.bo.filetype == "lua"
						end,
						module = "lazydev.integrations.blink",
						score_offset = 100,
					},
					git = {
						name = "Git",
						module = "blink-cmp-git",
						enabled = function()
							return vim.tbl_contains({ "gitcommit", "markdown" }, vim.bo.filetype)
						end,
					},
					conventional_commits = {
						name = "Conventional Commits",
						module = "blink-cmp-conventional-commits",
						enabled = function()
							return vim.bo.filetype == "gitcommit"
						end,
					},
				},
			},
			keymap = vim.tbl_deep_extend("keep", {
				preset = "none",
				["<M-d>"] = { "show_documentation", "hide_documentation" },
				-- menu open: first snippet · on a choiceNode: choice picker · else: signature
				["<M-s>"] = { accept_first_snippet, select_choice, "show_signature", "hide_signature" },
				-- snippet placeholder jumps
				-- (choice node cycling is <M-n>/<M-p>, mapped in snippets.lua)
				["<Tab>"] = { "snippet_forward", "fallback" },
				["<S-Tab>"] = { "snippet_backward", "fallback" },
			}, base_keymap),
			signature = { enabled = true, window = {
				border = "rounded",
				show_documentation = true,
			} },
			completion = {
				trigger = {
					-- keep the menu working while sitting in a snippet's insert node
					show_in_snippet = true,
				},
				list = {
					selection = { preselect = true, auto_insert = false },
				},
				accept = {
					auto_brackets = {
						enabled = true,
					},
				},
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 100,
					window = {
						border = "rounded",
					},
				},
				ghost_text = {
					enabled = true,
				},
				menu = {
					border = "rounded",
					auto_show = true,
					scrollbar = false,
					draw = {
						columns = {
							{ "kind_icon", "label", gap = 2 },
							{ "kind" },
						},
						components = {
							kind_icon = {
								text = function(ctx)
									return (cmp_kinds[ctx.kind] or ctx.kind_icon) .. ctx.icon_gap
								end,
							},
							kind = {
								text = function(ctx)
									return "(" .. ctx.kind .. ")"
								end,
								highlight = function(_)
									return "Comment"
								end,
							},
						},
					},
				},
			},
			cmdline = {
				keymap = vim.tbl_deep_extend("force", base_keymap, {
					["<M-h>"] = {
						function(cmp)
							if cmp.is_ghost_text_visible() then
								cmp.show()
							else
								if cmp.is_visible() then
									cmp.hide()
								else
									cmp.show()
								end
							end
						end,
					},
				}),
			},
		}
	end)
