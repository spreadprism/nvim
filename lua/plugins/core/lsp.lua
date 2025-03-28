---@param server_name string
local function get_capabilities(server_name)
	local capabilities = vim.lsp.protocol.make_client_capabilities()
	capabilities.textDocument.completion.completionItem.snippetSupport = true
	return capabilities
end

local function on_attach(_, bufnr)
	keymap("n", "K", function()
		local api = vim.api
		local hover_win = vim.b.hover_preview
		if hover_win and api.nvim_win_is_valid(hover_win) then
			api.nvim_set_current_win(hover_win)
		else
			require("hover").hover()
		end
	end, "Hover information", { buffer = bufnr, noremap = true }):load()
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
		}, plugin.lsp or {}))
	end,
	after = function()
		-- Symbols
		vim.fn.sign_define("DiagnosticSignError", { text = "", texthl = "DiagnosticSignError" })
		vim.fn.sign_define("DiagnosticSignWarn", { text = "", texthl = "DiagnosticSignWarn" })
		vim.fn.sign_define("DiagnosticSignInfo", { text = "", texthl = "DiagnosticSignInfo" })
		vim.fn.sign_define("DiagnosticSignHint", { text = "󰌵", texthl = "DiagnosticSignHint" })

		vim.diagnostic.config({
			signs = {
				--support diagnostic severity / diagnostic type name
				text = {
					[vim.diagnostic.severity.ERROR] = " ",
					[vim.diagnostic.severity.WARN] = " ",
					[vim.diagnostic.severity.HINT] = "󰌵",
					[vim.diagnostic.severity.INFO] = " ",
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
