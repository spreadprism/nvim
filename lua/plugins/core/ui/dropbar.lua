plugin("dropbar")
	:event("UIEnter")
	:keymaps(k:map("n", "<M-->", k.act:lazy("dropbar.api").pick(), "pick symbols in winbar"))
	:after(function()
		-- INFO: hide cursor on dropbar_menu
		vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter" }, {
			callback = function(data)
				local hl = vim.api.nvim_get_hl(0, { name = "Cursor", link = false })
				if vim.bo[data.buf].ft == "dropbar_menu" then
					vim.api.nvim_set_hl(0, "Cursor", { blend = 100, fg = hl.fg, bg = hl.bg })
					vim.opt_local.guicursor:append("a:Cursor/lCursor")
				else
					vim.api.nvim_set_hl(0, "Cursor", { blend = 0, fg = hl.fg, bg = hl.bg })
					vim.opt_local.guicursor:remove("a:Cursor/lCursor")
				end
			end,
		})
	end)
	:opts(function()
		local bar = require("dropbar.bar")
		local sources = require("dropbar.sources")
		local configs = require("dropbar.configs")

		local root = {
			get_symbols = function(buf, win, _)
				local root = configs.eval(configs.opts.sources.path.relative_to, buf, win)

				if root == vim.env.HOME then
					root = "~"
				elseif root ~= "/" then
					root = vim.fs.basename(root)
				end

				return {
					bar.dropbar_symbol_t:new({
						name = root,
						name_hl = "DropBarFileName",
					}),
				}
			end,
		}

		local path_modified = {
			get_symbols = function(buf, win, cursor)
				local symbols = sources.path.get_symbols(buf, win, cursor)
				if not vim.bo[buf].modified then
					return symbols
				end

				symbols[#symbols].name = symbols[#symbols].name .. " " .. internal.Symbols.modified

				return symbols
			end,
		}

		return {
			bar = {
				enable = function(buf, win, _)
					buf = vim._resolve_bufnr(buf)
					if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_win_is_valid(win) then
						vim.print("here")
						return false
					end

					if
						not vim.api.nvim_buf_is_valid(buf)
						or not vim.api.nvim_win_is_valid(win)
						or vim.fn.win_gettype(win) ~= ""
						or vim.wo[win].winbar ~= ""
						or vim.bo[buf].ft == "help"
					then
						return false
					end

					local stat = vim.uv.fs_stat(vim.api.nvim_buf_get_name(buf))
					if stat and stat.size > 1024 * 1024 then
						return false
					end

					return vim.tbl_contains({ "markdown", "oil" }, vim.bo[buf].ft)
						or pcall(vim.treesitter.get_parser, buf)
						or not vim.tbl_isempty(vim.lsp.get_clients({
							bufnr = buf,
							method = "textDocument/documentSymbol",
						}))
				end,
				sources = function(buf, _)
					local bt = vim.bo[buf].buftype
					local s = {
						terminal = { sources.terminal },
						oil = { root, sources.path },
						_ = { root, path_modified },
					}
					return s[bt] or s["_"]
				end,
			},
			sources = {
				path = {
					preview = false,
					relative_to = function(buf, win)
						local home = vim.env.HOME
						local ok, cwd = pcall(vim.fn.getcwd, win)
						if not ok then
							cwd = vim.fn.getcwd()
						end

						---@type string
						local buf_path = ""

						if vim.bo[buf].ft == "oil" then
							buf_path = require("oil").get_current_dir(buf) or ""
						else
							buf_path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":h")
						end

						if vim.startswith(buf_path, cwd) then
							return cwd
						end

						if vim.startswith(buf_path, home) then
							return home
						end

						return "/"
					end,
				},
			},
		}
	end)
