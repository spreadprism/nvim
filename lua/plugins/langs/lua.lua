-- plugin("lazydev.nvim"):on_require("lazydev"):cmd("LazyDev"):ft("lua"):opts({
-- 	library = require("internal.lazydev").paths,
-- })
formatter("lua", "stylua")
lsp("lua_ls")
	:cmd("lua-language-server")
	:ft("lua")
	:root_markers(
		".luarc.json",
		".luarc.jsonc",
		".luacheckrc",
		".stylua.toml",
		"stylua.toml",
		"selene.toml",
		"selene.yml",
		".nvim.lua",
		".git"
	)
	:settings({
		Lua = {
			runtime = { version = "LuaJIT" },
			workspace = {
				library = {
					vim.env.VIMRUNTIME,
				},
			},
			formatters = {
				ignoreComments = true,
			},
			signatureHelp = { enabled = true },
			diagnostics = {
				globals = {
					"nixCats",
					"vim",
					"cwd",
					"joinpath",
					"lsp",
					"plugin",
					"keymap",
					"kcmd",
					"keymapLoad",
					"kgroup",
				},
				disable = { "missing-fields", "different-requires" },
			},
			telemetry = { enabled = false },
		},
	})
