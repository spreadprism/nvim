plugin("heirline")
	:event("UIEnter")
	:dep_on({
		plugin("heirline-components"),
		"gitsigns",
	})
	:before(function()
		vim.o.laststatus = 3
	end)
	:opts(function()
		local heirline = require("heirline")
		local heirline_components = require("heirline-components.all")

		heirline_components.init.subscribe_to_events()
		heirline.load_colors(heirline_components.hl.get_colors())

		local pickers = {}

		vim.api.nvim_create_autocmd("User", {
			pattern = "PickerOnShowClose",
			callback = function(args)
				pickers = require("snacks.picker").get()
			end,
		})

		on_plugin("snacks", function()
			pickers = require("snacks.picker").get()
		end)

		return {
			statusline = require("internal.ui.statusline"),
			statuscolumn = require("internal.ui.statuscolumn"),
			winbar = require("internal.ui.winbar"),
			opts = {
				disable_winbar_cb = function(args)
					local win = vim.api.nvim_get_current_win()
					for _, picker in ipairs(pickers) do
						if picker and picker.preview and picker.preview.win and picker.preview.win.win == win then
							return true
						end
					end
					return require("heirline.conditions").buffer_matches({
						buftype = { "nofile", "prompt", "help", "quickfix" },
						filetype = {
							"^git.*",
							"fugitive",
							"Trouble",
							"dashboard",
							"^$",
							"terminal",
						},
					}, args.buf)
				end,
			},
		}
	end)
