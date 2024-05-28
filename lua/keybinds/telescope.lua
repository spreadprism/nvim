local finders = require("utils.telescope")
keybind_group("<leader>s", "Search"):register({
	keybind("n", "f", finders.find_files(), "Search files"),
	keybind("n", "l", finders.resume(), "Reopen last search"),
	keybind("n", "g", finders.live_grep(true), "Grep current buffer"),
	keybind("n", "G", finders.live_grep(false), "Grep search cwd"),
	keybind("n", "z", finders.fuzzy_live_grep(true), "Fuzzy find current buffer"),
	keybind("n", "Z", finders.fuzzy_live_grep(false), "Fuzzy find cwd"),
})
