---@param server_name string
local function get_capabilities(server_name)
	local capabilities = vim.lsp.protocol.make_client_capabilities()
	capabilities.textDocument.completion.completionItem.snippetSupport = true
	return capabilities
end

local function on_attach(_, bufnr)
	keymapLoad({
		keymap({ "n", "v" }, "gd", function()
			require("telescope.builtin").lsp_definitions()
		end, "go to definition"),
		keymap({ "n", "v" }, "gt", function()
			require("telescope.builtin").lsp_type_definitions()
		end, "go to type"),
		keymap({ "n", "v" }, "gr", function()
			require("telescope.builtin").lsp_references()
		end, "go to reference"),
		keymap("n", "<F2>", vim.lsp.buf.rename, "rename"),
	})
end

plugin("neoconf.nvim"):on_require("neoconf"):on_plugin("nvim-lspconfig"):opts({
	import = {
		coc = false,
		nlsp = false,
	},
	plugins = {
		lua_ls = {
			enabled = true,
		},
	},
})
require("lze").load({
	"nvim-lspconfig",
	for_cat = "core",
	on_require = { "lspconfig" },
	lsp = function(plugin)
		local o_a = on_attach
		if plugin.lsp.on_attach then
			o_a = function(_, bufnr)
				plugin.lsp.on_attach(_, bufnr)
				on_attach(_, bufnr)
			end
			plugin.lsp.on_attach = o_a
		end
		require("lspconfig")[plugin.name].setup(vim.tbl_extend("force", {
			capabilities = get_capabilities(plugin.name),
			on_attach = o_a,
		}, plugin.lsp or {}))
	end,
	after = function()
		vim.diagnostic.config({
			signs = {
				--support diagnostic severity / diagnostic type name
				text = {
					[vim.diagnostic.severity.ERROR] = Symbols.error,
					[vim.diagnostic.severity.WARN] = Symbols.warn,
					[vim.diagnostic.severity.HINT] = Symbols.hint,
					[vim.diagnostic.severity.INFO] = Symbols.info,
				},
			},
		})

		vim.cmd([[highlight DiagnosticUnderlineError guifg=#db4b4b]])
		vim.cmd([[highlight DiagnosticUnderlineWarn guifg=#e0af68]])
		vim.cmd([[highlight DiagnosticDeprecated guifg=#e0af68]])
		vim.cmd([[highlight DiagnosticUnderlineInfo guifg=#0db9d7]])
		vim.cmd([[highlight DiagnosticInfo guifg=#0db9d7]])

		require("lspconfig.ui.windows").default_options.border = "rounded"
	end,
})

keymapGroup("<leader>l", "lsp", {
	keymap("n", "i", keymapCmd("LspInfo"), "Info"),
	keymap("n", "r", keymapCmd("LspRestart"), "Restart language server"),
	keymap("n", "s", keymapCmd("NeoConf show"), "Show LSP settings"),
	keymap("n", "e", keymapCmd("NeoConf"), "Edit LSP settings"),
})

plugin("hover.nvim")
	:on_require("hover")
	:opts({
		init = function()
			require("hover.providers.lsp")
		end,
		preview_opts = {
			border = "rounded",
		},
		title = false,
	})
	:keys({
		keymap("n", "K", function()
			local api = vim.api
			local hover_win = vim.b.hover_preview
			if hover_win and api.nvim_win_is_valid(hover_win) then
				api.nvim_set_current_win(hover_win)
			else
				require("hover").hover()
			end
		end, "hover"),
	})
