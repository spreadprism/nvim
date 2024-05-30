local finders = require("utils.telescope")
local builtin = require("telescope.builtin")
keybind_group("<leader>s", "Search"):register({
	keybind("n", "f", finders.find_files(), "Search files"),
	keybind("n", "l", finders.resume(), "Reopen last search"),
	keybind("n", "g", finders.live_grep(true), "Grep current buffer"),
	keybind("n", "G", finders.live_grep(false), "Grep search cwd"),
	keybind("n", "z", finders.fuzzy_live_grep(true), "Fuzzy find current buffer"),
	keybind("n", "Z", finders.fuzzy_live_grep(false), "Fuzzy find cwd"),
	keybind_group("d", "diagnostics", {
		keybind("n", "a", function()
			builtin.diagnostics({ bufnr = 0 })
		end, "all (current buffer)"),
		keybind("n", "A", function()
			builtin.diagnostics({ bufnr = nil })
		end, "all"),
		keybind("n", "e", function()
			builtin.diagnostics({ bufnr = 0, severity = vim.diagnostic.severity.ERROR })
		end, "errors (current buffer)"),
		keybind("n", "E", function()
			builtin.diagnostics({ bufnr = nil, severity = vim.diagnostic.severity.ERROR })
		end, "errors"),
		keybind("n", "w", function()
			builtin.diagnostics({ bufnr = 0, severity = vim.diagnostic.severity.WARN })
		end, "warnings (current buffer)"),
		keybind("n", "W", function()
			builtin.diagnostics({ bufnr = nil, severity = vim.diagnostic.severity.WARN })
		end, "warnings"),
		keybind("n", "h", function()
			builtin.diagnostics({ bufnr = 0, severity = vim.diagnostic.severity.HINT })
		end, "hint (current buffer)"),
		keybind("n", "H", function()
			builtin.diagnostics({ bufnr = nil, severity = vim.diagnostic.severity.HINT })
		end, "hint"),
	}),
})
