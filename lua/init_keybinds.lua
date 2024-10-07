-- TODO: Should depend on the LazyLoad event to trigger keybinds when a certain module is loaded
for _, keybind in ipairs(require("internal.module").list_submodules("keybinds", "*", true) or {}) do
	local ok, _ = pcall(require, keybind)

	if not ok then
		vim.notify("Failed to load keybinds from " .. keybind, vim.log.levels.ERROR, { title = "Keybinds" })
	end
end
