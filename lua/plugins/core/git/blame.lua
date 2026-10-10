plugin("blame")
	:cmd("BlameToggle")
	:opts({
		mappings = {},
	})
	:keymaps({
		k:map("n", "<M-B>", k:cmd("BlameToggle"), "Toggle blame"),
	})
	:after(function()
		vim.api.nvim_create_autocmd("User", {
			pattern = "BlameViewOpened",
			callback = function(event)
				local blame_type = event.data
				local get_hash = function()
					local window = require("blame").last_opened_view
					if not window then
						return nil
					end
					local row, _ = unpack(vim.api.nvim_win_get_cursor(window.blame_window))
					local commit = window.blamed_lines[row]
					return commit.hash
				end
				if blame_type == "window" then
					vim.defer_fn(function()
						local buf = vim.api.nvim_get_current_buf()
						k:opts({
							k:map("n", "<CR>", function()
								local hash = get_hash()
								if hash then
									require("blame").last_opened_view:close()
									require("internal.git").commit(hash, { kind = "tab" })
								end
							end, "open commit"),
							k:map("n", "d", function()
								local hash = get_hash()
								if hash then
									require("blame").last_opened_view:close()
									vim.cmd(":DiffviewOpen " .. hash .. "^.." .. hash)
								end
							end, "open commit"),
						})
							:buffer(buf)
							:add()
					end, 50)
				end
			end,
		})
	end)
