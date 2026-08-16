plugin("luasnip")
	:event("DeferredUIEnter")
	:opts({
		history = true,
		update_events = { "InsertLeave" },
	})
	:on_highlights(function(highlights, colors)
		highlights.LuasnipChoice = { fg = colors.purple, bg = "NONE" }
	end)
	:after(function()
		require("luasnip.loaders.from_lua").load({
			paths = {
				vim.fs.joinpath(nixcats.configDir, "lua", "snippets"),
			},
		})
		require("templates").setup()

		-- choiceNode cycling. The <Plug> mappings are LuaSnip's documented
		-- interface and handle the mode/state juggling themselves.
		vim.keymap.set({ "i", "s" }, "<M-n>", "<Plug>luasnip-next-choice", { silent = true })
		vim.keymap.set({ "i", "s" }, "<M-p>", "<Plug>luasnip-prev-choice", { silent = true })

		-- <M-1>..<M-9> jump straight to that choice
		for idx = 1, 9 do
			vim.keymap.set({ "i", "s" }, ("<M-%d>"):format(idx), function()
				local ls = require("luasnip")
				if not ls.choice_active() then
					return
				end
				local ok, err = pcall(function()
					ls.set_choice(idx)
					-- Queued behind luasnip's own pending actions; a plain
					-- vim.schedule would run too early.
					require("luasnip.util.feedkeys").enqueue_action(function()
						local session = require("luasnip.session")
						local buf = vim.api.nvim_get_current_buf()
						-- set_choice already moves the cursor INTO the new
						-- choice when it holds an editable node (e.g. `T` in
						-- "(T, error)"). Only move on when it doesn't, which
						-- is when the choiceNode itself is still current.
						if session.current_nodes[buf] == session.active_choice_nodes[buf] then
							pcall(ls.jump, 1)
						end
					end)
				end)
				if not ok then
					vim.notify(("[luasnip] choice %d: %s"):format(idx, err), vim.log.levels.WARN)
				end
			end, { silent = true, desc = "LuaSnip: select choice " .. idx })
		end

		-- Ghost text listing the available choices while sitting on a choiceNode.
		local ns = vim.api.nvim_create_namespace("luasnip_choices")
		local marked_buf

		local function close_choices()
			if marked_buf and vim.api.nvim_buf_is_valid(marked_buf) then
				vim.api.nvim_buf_clear_namespace(marked_buf, ns, 0, -1)
			end
			marked_buf = nil
		end

		-- Row of the active choiceNode itself (0-indexed, as extmarks want).
		-- Reading the cursor instead is unreliable: it has not always landed
		-- yet, which put the ghost text a line off when jumping backwards.
		local function choice_row(buf)
			local ok, session = pcall(require, "luasnip.session")
			if not ok then
				return nil
			end
			local node = session.active_choice_nodes and session.active_choice_nodes[buf]
			if not node or type(node.get_buf_position) ~= "function" then
				return nil
			end
			local got, from = pcall(node.get_buf_position, node)
			if not got or type(from) ~= "table" then
				return nil
			end
			-- tolerate both `from, to` and `{ from, to }` return shapes
			local row = type(from[1]) == "table" and from[1][1] or from[1]
			return type(row) == "number" and row or nil
		end

		local function show_choices()
			close_choices()

			-- The choiceNode can be gone by the time this deferred call runs (we
			-- may have jumped away). get_current_choices() *asserts* in that
			-- case, so check first.
			local ls = require("luasnip")
			if not ls.choice_active() then
				return
			end
			local ok, choices = pcall(ls.get_current_choices)
			if not ok or not choices or vim.tbl_isempty(choices) then
				return
			end

			local parts = {}
			for idx, choice in ipairs(choices) do
				-- docstrings may span lines; keep the ghost text on one line
				local text = choice:gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1")
				table.insert(parts, ("%d. %s"):format(idx, text ~= "" and text or "<empty>"))
			end

			local buf = vim.api.nvim_get_current_buf()
			local row = choice_row(buf) or (vim.fn.line(".") - 1)

			marked_buf = buf
			pcall(vim.api.nvim_buf_set_extmark, marked_buf, ns, row, 0, {
				virt_text = { { "  " .. table.concat(parts, "  "), "LuasnipChoice" } },
				virt_text_pos = "eol",
				hl_mode = "combine",
			})
		end

		-- Queue behind luasnip's pending cursor movements. vim.schedule alone can
		-- run before the cursor has landed, which puts the ghost text on the
		-- previous line (noticeable when jumping backwards with <S-Tab>).
		local function defer(fn)
			local ok, feedkeys = pcall(require, "luasnip.util.feedkeys")
			if ok and feedkeys.enqueue_action then
				feedkeys.enqueue_action(fn)
			else
				vim.schedule(fn)
			end
		end

		local group = vim.api.nvim_create_augroup("LuasnipChoicePopup", { clear = true })
		vim.api.nvim_create_autocmd("User", {
			group = group,
			pattern = { "LuasnipChoiceNodeEnter", "LuasnipChangeChoice" },
			callback = function()
				defer(show_choices)
			end,
		})
		vim.api.nvim_create_autocmd("User", {
			group = group,
			pattern = "LuasnipChoiceNodeLeave",
			callback = close_choices,
		})
		vim.api.nvim_create_autocmd({ "InsertLeave", "BufLeave" }, {
			group = group,
			callback = close_choices,
		})
	end)
