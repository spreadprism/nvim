keybind("n", "<M-c>", function()
	require("dapui").toggle(2)
end, "Toggle dap console"):register()
keybind("n", "<M-r>", function()
	require("dapui").toggle(1)
end, "Toggle dap repl"):register()
keybind("n", "<M-R>", function()
	require("dapui").float_element("repl", {})
end, "Toggle dap repl"):register()
