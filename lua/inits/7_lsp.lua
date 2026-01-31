local loader = require("internal.loader")

loader.load_lsp_config()

vim.lsp.config("*", {
	root_markers = { ".nvim.lua", ".git" },
})

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client ~= nil then
			require("internal.loader.lsp").on_attach(client, args.buf)
			k:opts({
				k:map("nv", "gd", k:require("snacks.picker").lsp_definitions(), "go to definition"),
				k:map("nv", "gt", k:require("snacks.picker").lsp_type_definitions(), "go to definition"),
				k:map("nv", "gr", k:require("snacks.picker").lsp_references(), "go to references"),
				k:map("nv", "gi", k:require("snacks.picker").lsp_implementations(), "go to implementation"),
				k:map("n", "<F2>", vim.lsp.buf.rename, "rename"),
				k:group("lsp", "<leader>l", {
					k:map({ "n", "v" }, "a", vim.lsp.buf.code_action, "code actions"),
				}),
				k:map("n", "<M-a>", function()
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
				:buffer(args.buf)
				:add()
		end
	end,
})

k:del("n", "gra")
k:del("n", "grn")
k:del("n", "gri")
k:del("n", "grr")
k:del("n", "grt")

vim.fn.sign_define("DiagnosticSignError", { text = "", texthl = "DiagnosticSignError" })
vim.fn.sign_define("DiagnosticSignWarn", { text = "", texthl = "DiagnosticSignWarn" })
vim.fn.sign_define("DiagnosticSignInfo", { text = "", texthl = "DiagnosticSignInfo" })
vim.fn.sign_define("DiagnosticSignHint", { text = "󰌵", texthl = "DiagnosticSignHint" })

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
			[vim.diagnostic.severity.WARN] = Symbols.warning,
			[vim.diagnostic.severity.HINT] = Symbols.hint,
			[vim.diagnostic.severity.INFO] = Symbols.info,
		},
	},
})

vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { fg = colors.error, undercurl = true })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", { fg = colors.warning, undercurl = true })
vim.api.nvim_set_hl(0, "DiagnosticDeprecated", { fg = colors.warning })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo", { fg = colors.info, undercurl = true })
vim.api.nvim_set_hl(0, "DiagnosticInfo", { fg = colors.info })

vim.lsp.log.set_level(vim.env.NVIM_LSP_LOG_LEVEL or "OFF")

k:group("lsp", "<leader>l", {
	k:map("n", "i", k:cmd("LspInfo"), "Info"),
	k:map("n", "r", function()
		local bufnr = vim.fn.bufnr()
		local clients = vim.lsp.get_clients({ bufnr = bufnr })
		for _, client in ipairs(clients) do
			if client.name == "copilot" then
				goto continue
			end
			client:stop(true)
			vim.defer_fn(function()
				vim.lsp.start(client.config, {
					bufnr = bufnr,
				})
			end, 1000)
			::continue::
		end
	end, "Restart language server"),
}):add()
