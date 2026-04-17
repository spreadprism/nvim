---@enum TroubleSeverity
local TroubleSeverity = {
	ERROR = 1,
	WARN = 2,
	INFO = 3,
	HINT = 4,
}

---@param severity_switch TroubleSeverity
local function filterSwitch(severity_switch)
	return function(view)
		local f = view:get_filter("severity")
		local severity = (f and f.filter.severity or 0)
		if severity ~= severity_switch then
			severity = severity_switch
		else
			severity = 0
		end
		view:filter({ severity = severity }, {
			id = "severity",
			template = "{hl:Title}Filter:{hl} {severity}",
			del = severity == 0,
		})
	end
end

plugin("trouble")
	:cmd("Trouble")
	:opts({
		focus = true,
		auto_preview = false,
		keys = {
			["<cr>"] = "jump_close",
			["<Tab>"] = "preview",
			["<C-e>"] = {
				action = filterSwitch(TroubleSeverity.ERROR),
				desc = "toggle errors",
			},
			["<C-w>"] = {
				action = filterSwitch(TroubleSeverity.WARN),
				desc = "toggle warnings",
			},
			["<C-i>"] = {
				action = filterSwitch(TroubleSeverity.INFO),
				desc = "toggle info",
			},
			["<C-h>"] = {
				action = filterSwitch(TroubleSeverity.HINT),
				desc = "toggle hints",
			},
		},
	})
	:keymaps({
		k:map("n", "<M-d>", k:cmd("Trouble diagnostics toggle filter.buf=0"), "diagnostics (buffer)"),
		k:map("n", "<M-D>", k:cmd("Trouble diagnostics toggle"), "diagnostics"),
	})
	:on_highlights(function(highlights, colors)
		highlights.TroubleNormal = { bg = colors.none }
	end)
