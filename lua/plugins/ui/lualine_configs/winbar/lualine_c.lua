local bar = {}
for _, component in ipairs(require("internal.winbar_components.location").component) do
	table.insert(bar, component)
end
table.insert(bar, require("internal.winbar_components.harpoon").component)
table.insert(bar, require("internal.winbar_components.dapui").component)
return bar
