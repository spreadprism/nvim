---@param server_name string
local function get_capabilities(server_name)
	local capabilities = vim.lsp.protocol.make_client_capabilities()
	capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)
	return capabilities
end

local function on_attach(_, bufnr)
	kmap({ "n", "v" }, "gd", function()
		require("telescope.builtin").lsp_definitions()
	end, "go to definition")
	kmap({ "n", "v" }, "gt", function()
		require("telescope.builtin").lsp_type_definitions()
	end, "go to type")
	kmap({ "n", "v" }, "gr", function()
		require("telescope.builtin").lsp_references()
	end, "go to reference")
	kmap("n", "<F2>", vim.lsp.buf.rename, "rename")
	kgroup("<leader>l", "lsp", {}, {
		kmap({ "n", "v" }, "a", vim.lsp.buf.code_action, "code actions"),
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

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(t)
		local path = vim.api.nvim_buf_get_name(t.buf)
		-- if it matches */nvim/lua/templates/*
		if path:match("nvim/lua/templates") then
			for _, client in pairs(vim.lsp.get_actc({ bufnr = t.buf })) do
				vim.defer_fn(function()
					pcall(vim.lsp.buf_detach_client, t.buf, client.id)
				end, 10)
			end
		end
	end,
})

require("lze").load({
	"nvim-lspconfig",
	for_cat = "core",
	on_require = { "lspconfig" },
	event = "User",
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
		vim.api.nvim_exec_autocmds("FileType", {})
	end,
	after = function()
		-- Symbols
		vim.fn.sign_define("DiagnosticSignError", { text = "", texthl = "DiagnosticSignError" })
		vim.fn.sign_define("DiagnosticSignWarn", { text = "", texthl = "DiagnosticSignWarn" })
		vim.fn.sign_define("DiagnosticSignInfo", { text = "", texthl = "DiagnosticSignInfo" })
		vim.fn.sign_define("DiagnosticSignHint", { text = "󰌵", texthl = "DiagnosticSignHint" })

		vim.diagnostic.config({
			virtual_text = {
				enabled = true,
				source = "if_many",
				prefix = "● ",
			},
			-- virtual_lines = {
			-- 	enabled = false,
			-- 	source = "if_many",
			-- 	severity = {
			-- 		min = vim.diagnostic.severity.ERROR,
			-- 	},
			-- },
			update_in_insert = true,
			underline = true,
			severity_sort = true,
			float = {
				border = "rounded",
				header = "",
				prefix = "",
			},
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

kgroup("<leader>l", "lsp", {}, {
	kmap("n", "i", kcmd("LspInfo"), "Info"),
	kmap("n", "r", kcmd("LspRestart"), "Restart language server"),
	kmap("n", "s", kcmd("LspStart"), "Start language server"),
	kmap("n", "S", kcmd("LspStop"), "Start language server"),
	kmap("n", "e", kcmd("Neoconf"), "Edit LSP settings"),
})

plugin("hover.nvim")
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
		kmap("n", "K", function()
			local api = vim.api
			local hover_win = vim.b.hover_preview
			if hover_win and api.nvim_win_is_valid(hover_win) then
				api.nvim_set_current_win(hover_win)
			else
				require("hover").hover()
			end
		end, "hover"),
	})
