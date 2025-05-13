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
}
plugin("blink-compat"):dep_of("blink.cmp"):on_require("blink.compat")
local default = {
	"lsp",
	"path",
	"snippets",
	"buffer",
}
plugin("blink.cmp"):event_typing():on_require("blink"):opts({
	snippets = { preset = "luasnip" },
	sources = {
		default = default,
		per_filetype = {
			lua = vim.list_extend({ "lazydev" }, default),
			sql = { "dbee", "buffer" },
		},
		providers = {
			lazydev = {
				name = "LazyDev",
				module = "lazydev.integrations.blink",
				score_offset = 100,
			},
			dbee = { name = "cmp-dbee", module = "blink.compat.source" },
		},
	},
	keymap = vim.tbl_deep_extend("keep", {
		preset = "none",
		["<M-d>"] = { "show_documentation", "hide_documentation" },
		["<M-s>"] = { "show_signature", "hide_signature" },
		["<M-l>"] = {
			function(cmp)
				if cmp.is_visible() then
					cmp.hide()
				end
				require("copilot.suggestion").next()
			end,
		},
		["<M-n>"] = { "snippet_forward", "fallback" },
		["<M-p>"] = { "snippet_backward" },
	}, base_keymap),
	signature = { enabled = true, window = {
		border = "rounded",
		show_documentation = true,
	} },
	completion = {
		list = {
			selection = { preselect = true, auto_insert = false },
		},
		accept = {
			auto_brackets = {
				enabled = false,
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
})
