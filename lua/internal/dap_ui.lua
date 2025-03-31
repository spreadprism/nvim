local M = {}

M.dap_ui_ft = {
	"dap-repl",
	"dapui_console",
	"dapui_watches",
	"dapui_stacks",
	"dapui_breakpoints",
	"dapui_scopes",
}

---@enum ui_layouts
M.ui_layouts = {
	sidebar = 1,
	repl = 2,
	console = 3,
}

---@enum ui_overlays
M.overlays = {
	REPL = 1,
	CONSOLE = 2,
}

local overlays_layout = {
	[M.overlays.REPL] = {
		M.ui_layouts.sidebar,
		M.ui_layouts.repl,
	},
	[M.overlays.CONSOLE] = {
		M.ui_layouts.sidebar,
		M.ui_layouts.console,
	},
}

local function repl_layout()
	return {
		elements = {
			{
				id = "repl",
				size = 1,
			},
		},
		position = "bottom",
		size = 0.3,
	}
end

local function console_layout()
	return {
		elements = {
			{
				id = "console",
				size = 1,
			},
		},
		position = "bottom",
		size = 0.3,
	}
end

local function sidebar_layout()
	return {
		elements = {
			{ id = "stacks", size = 0.5 },
			{ id = "watches", size = 0.25 },
			{ id = "scopes", size = 0.25 },
		},
		position = "right",
		size = 0.25,
	}
end

function M.close()
	require("dapui").close()
end

---@param overlay ui_overlays
function M.set_overlay(overlay)
	M.close()
	for _, l in ipairs(overlays_layout[overlay] or {}) do
		require("dapui").open({ layout = l })
	end
end

function M.generate_layouts()
	local layouts = {}
	table.insert(layouts, M.ui_layouts.sidebar, sidebar_layout())
	table.insert(layouts, M.ui_layouts.repl, repl_layout())
	table.insert(layouts, M.ui_layouts.console, console_layout())
	return layouts
end

return M
