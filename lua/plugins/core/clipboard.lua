plugin("nvim-osc52")
	:for_cat("remote")
	:envPresent({
		"SSH_CLIENT",
		"SSH_TTY",
	})
	:event("DeferredUIEnter")
	:after(function()
		local osc = require("osc52")
		osc.setup({
			tmux_passthrough = true,
			silent = true,
			trim = true,
		})
		local function copy(lines, _)
			require("osc52").copy(table.concat(lines, "\n"))
		end

		local function paste()
			return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
		end

		vim.g.clipboard = {
			name = "osc52",
			copy = { ["+"] = copy, ["*"] = copy },
			paste = { ["+"] = paste, ["*"] = paste },
		}
	end)
