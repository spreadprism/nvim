plugin("lspconfig")
	:opts(false)
	:after(function()
		vim.lsp.config("*", {
			root_markers = { ".nvim.lua", ".git" },
		})
		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function(args)
				local client = vim.lsp.get_client_by_id(args.data.client_id)
				if client ~= nil then
					if client:supports_method("textDocument/inlayHint") then
						vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
					end
					k:opts({
						-- k:map("n", "<leader>fs", k:require("snacks.picker").lsp_symbols(), "lsp symbols"),
						-- k:map(
						-- 	"n",
						-- 	"<M-S>",
						-- 	k:require("snacks.picker").lsp_workspace_symbols(),
						-- 	"workspace lsp symbols"
						-- ),
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
					[vim.diagnostic.severity.ERROR] = symbols.error,
					[vim.diagnostic.severity.WARN] = symbols.warning,
					[vim.diagnostic.severity.HINT] = symbols.hint,
					[vim.diagnostic.severity.INFO] = symbols.info,
				},
			},
		})
		vim.lsp.log.set_level(vim.env.NVIM_LSP_LOG_LEVEL or "OFF")

		-- DirChanged only reports the new cwd, so remember the previous one.
		local prev_cwd = vim.fs.normalize(vim.fn.getcwd())

		---@param dir string
		---@param root string?
		local function is_under(dir, root)
			if not root then
				return false
			end
			root = vim.fs.normalize(root)
			return root == dir or vim.startswith(root, dir .. "/")
		end

		vim.api.nvim_create_autocmd("DirChanged", {
			group = vim.api.nvim_create_augroup("lsp_dir_changed", { clear = true }),
			desc = "stop language servers rooted in the previous cwd",
			callback = function(ev)
				-- only a global :cd switches workspace
				if ev.match ~= "global" then
					return
				end

				local old = prev_cwd
				local new = vim.fs.normalize(vim.v.event.cwd or vim.fn.getcwd())
				prev_cwd = new
				if old == new then
					return
				end

				for _, client in ipairs(vim.lsp.get_clients()) do
					-- keep clients that also cover the directory we moved into
					if is_under(old, client.root_dir) and not is_under(new, client.root_dir) then
						client:stop(true)
					end
				end
			end,
		})
	end)
	:keymaps(k:group("lsp", "<leader>l", {
		k:map("n", "i", k:cmd("checkhealth vim.lsp"), "info"),
		k:map("n", "r", k:cmd("lsp restart"), "restart"),
	}))
	:on_highlights(function(highlights, colors)
		highlights.DiagnosticUnderlineError = { fg = colors.error, undercurl = true }
		highlights.DiagnosticUnderlineWarn = { fg = colors.warning, undercurl = true }
		highlights.DiagnosticDeprecated = { fg = colors.warning }
		highlights.DiagnosticUnderlineInfo = { fg = colors.info, undercurl = true }
		highlights.DiagnosticInfo = { fg = colors.info }
		highlights.LspInlayHint = { fg = colors.purple, bg = "NONE" }
	end)
	:lazy(false)
