if nixCats("core.colorscheme") then
	vim.cmd("colorscheme tokyonight-storm")
	if nixCats("devtools") then
		plugin("ex-colors"):cmd("ExColors"):opts({
			colors_dir = joinpath(cwd(), "colors"),
		})
	end
	local transparent = require("transparent")
	transparent.setup({
		exclude_groups = {
			"TelescopeSelection",
			"TelescopePreviewLine",
			"BlinkCmpMenuSelection",
			"BlinkCmpScrollBarGutter",
		},
	})
	transparent.clear_prefix("BlinkCmp")
	transparent.clear_prefix("Telescope")
	transparent.clear_prefix("Trouble")
	transparent.clear_prefix("DiffviewFilePanel")
	transparent.clear_prefix("Notify")
	transparent.clear_prefix("OilVcsStatus")
	transparent.clear_prefix("WhichKey")
	transparent.clear_prefix("Float")
	transparent.clear_prefix("Flash")
	transparent.clear_prefix("NormalFloat")
	transparent.clear_prefix("LspInlayHint")
end
