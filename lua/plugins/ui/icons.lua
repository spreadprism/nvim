local devicons = require("nvim-web-devicons")
devicons.setup({
	default = true,
	strict = false,
	override_by_filename = require("icons.filename"),
	override_by_extension = require("icons.extension"),
})

local function get_ext(name)
	for _, p_ft in pairs(require("icons.pattern")) do
		local pattern = p_ft[1]
		local ext = p_ft[2]
		if name:find(pattern) then
			return ext
		end
	end
	return name:match("^.*%.(.*)$") or ""
end

local get_icon = devicons.get_icon
devicons.get_icon = function(name, ext, opts)
	return get_icon(name, ext or get_ext(name), opts)
end
devicons.set_icon_by_filetype(require("icons.filetype"))
