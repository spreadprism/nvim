-- TODO: Add the possibility for this to be triggered from the lsp definition
---@param client vim.lsp.Client
---@param buf integer
local function on_attach(client, buf)
	local actions = {
		["lua_ls"] = function()
			require("neoconf")
		end,
		ruff = function()
			client.server_capabilities.hoverProvider = false
		end,
		tofu_ls = function()
			client.server_capabilities.semanticTokensProvider = nil
		end,
	}

	if actions[client.name] ~= nil then
		actions[client.name]()
	end

	if client.server_capabilities.inlayHintProvider then
		vim.lsp.inlay_hint.enable(true, {
			bufnr = buf,
		})
	end
end

---@param buf integer
local function set_lsp_keymaps(buf)
	kopts({ buffer = buf }, {
		kmap({ "n", "v" }, "gd", klazy("snacks.picker").lsp_definitions(), "go to definition"),
		kmap({ "n", "v" }, "gt", klazy("snacks.picker").lsp_type_definitions(), "go to type definition"),
		kmap({ "n", "v" }, "gr", klazy("snacks.picker").lsp_references(), "go to reference"),
		kmap({ "n", "v" }, "gi", klazy("snacks.picker").lsp_implementations(), "go to implementations"),
		kmap({ "n", "v" }, "K", function()
			vim.lsp.buf.hover()
		end, "hover"),
		kmap("n", "<F2>", vim.lsp.buf.rename, "rename"),
		kgroup("<leader>l", "lsp", {}, {
			kmap({ "n", "v" }, "a", vim.lsp.buf.code_action, "code actions"),
		}),
		kmap("n", "<M-a>", function()
			vim.diagnostic.open_float({
				border = "rounded",
				scope = "line",
				prefix = function(_, i, total)
					if total == 1 then
						return "", ""
					end
					return "(" .. i .. "/" .. total .. ") ", ""
				end,
				source = true,
			})
		end, "diagnostic float"),
	})
end

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client ~= nil then
			on_attach(client, args.buf)
			set_lsp_keymaps(args.buf)
		end
	end,
})

vim.keymap.del("n", "gra")
vim.keymap.del("n", "grn")
vim.keymap.del("n", "gri")
vim.keymap.del("n", "grr")
vim.keymap.del("n", "grt")

vim.fn.sign_define("DiagnosticSignError", { text = "", texthl = "DiagnosticSignError" })
vim.fn.sign_define("DiagnosticSignWarn", { text = "", texthl = "DiagnosticSignWarn" })
vim.fn.sign_define("DiagnosticSignInfo", { text = "", texthl = "DiagnosticSignInfo" })
vim.fn.sign_define("DiagnosticSignHint", { text = "󰌵", texthl = "DiagnosticSignHint" })

vim.lsp.config("*", {
	root_markers = { ".git" },
})

vim.diagnostic.config({
	virtual_text = {
		enabled = true,
		prefix = "●",
	},

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

vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { fg = "#db4b4b", undercurl = true })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", { fg = "#e0af68", undercurl = true })
vim.api.nvim_set_hl(0, "DiagnosticDeprecated", { fg = "#e0af68" })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo", { fg = "#0db9d7", undercurl = true })
vim.api.nvim_set_hl(0, "DiagnosticInfo", { fg = "#0db9d7" })

vim.lsp.log.set_level(env.get("NVIM_LSP_LOG_LEVEL") or "OFF")

kgroup("<leader>l", "lsp", {}, {
	kmap("n", "i", kcmd("LspInfo"), "Info"),
	kmap("n", "r", function()
		local bufnr = vim.fn.bufnr()
		local clients = vim.lsp.get_clients({ bufnr = bufnr })
		for _, client in ipairs(clients) do
			if client.name == "copilot" then
				goto continue
			end
			vim.lsp.stop_client(client.id, true)
			vim.defer_fn(function()
				vim.lsp.start(client.config, {
					bufnr = bufnr,
				})
			end, 1000)
			::continue::
		end
	end, "Restart language server"),
})

local function filterSwitch(severity_switch)
	return function(view)
		local f = view:get_filter("severity")
		local severity = (f and f.filter.severity or 0)
		if severity ~= severity_switch then
			severity = severity_switch
		else
			severity = 0
		end
		view:filter({ severity = severity }, {
			id = "severity",
			template = "{hl:Title}Filter:{hl} {severity}",
			del = severity == 0,
		})
	end
end
plugin("trouble")
	:on_require("trouble")
	:cmd("Trouble")
	:opts({
		focus = true,
		auto_preview = false,
		keys = {
			["<cr>"] = "jump_close",
			["<Tab>"] = "preview",
			["<C-e>"] = {
				action = filterSwitch(1),
				desc = "toggle errors",
			},
			["<C-w>"] = {
				action = filterSwitch(2),
				desc = "toggle warnings",
			},
			["<C-i>"] = {
				action = filterSwitch(3),
				desc = "toggle info",
			},
			["<C-h>"] = {
				action = filterSwitch(4),
				desc = "toggle hints",
			},
		},
	})
	:keys({
		kmap("n", "<M-d>", kcmd("Trouble diagnostics toggle filter.buf=0"), "diagnostics (buffer)"),
		kmap("n", "<M-D>", kcmd("Trouble diagnostics toggle"), "diagnostics (buffer)"),
	})
plugin("neoconf.nvim"):on_require("neoconf"):opts({
	import = {
		coc = false,
		nlsp = false,
	},
	plugins = {
		lspconfig = {
			enabled = false,
		},
		lua_ls = {
			enabled = true,
		},
	},
})
