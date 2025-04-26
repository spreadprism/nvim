local function copy(lines, _)
	require("osc52").copy(table.concat(lines, "\n"))
end

local function paste()
	return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
end
plugin("nvim-osc52")
	:on_require("osc52")
	:for_cat("remote")
	:event_defer()
	:env_enabled({
		"SSH_CLIENT",
		"SSH_TTY",
	})
	:set_g_options({
		clipboard = {
			name = "osc52",
			copy = { ["+"] = copy, ["*"] = copy },
			paste = { ["+"] = paste, ["*"] = paste },
		},
	})
	:opts({
		tmux_passthrough = true,
		silent = true,
		trim = true,
	})
