local custom_handlers = require("internal.loader.plugin.handler")

for _, handler in ipairs({
	require("lzextras").merge,
	require("nixCats.utils").for_cat,
	custom_handlers.setup,
	custom_handlers.keymaps,
}) do
	require("lze").register_handlers(handler)
end
