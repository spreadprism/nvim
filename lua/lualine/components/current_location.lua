-- TODO: cleanup this component, its all over the place
local component = require("lualine.component"):extend()
local lualine_require = require("lualine_require")
local modules = lualine_require.lazy_require({
	highlight = "lualine.highlight",
	utils = "lualine.utils.utils",
})

local default_options = {
	symbols = {
		separator = "",
		modified = "[+]",
		readonly = "[-]",
		unnamed = "[No Name]",
		newfile = "[New]",
	},
	exclude_filetypes = {},
}

local always_exclude = {
	"netrw",
	"toggleterm",
	"noice",
	"vim",
	"qf",
	"startuptime",
	"trouble",
}

function component:init(options)
	component.super.init(self, options)
	self.options = vim.tbl_deep_extend("force", default_options, options or {})
	for _, exclude in ipairs(always_exclude) do
		table.insert(self.options.exclude_filetypes, exclude)
	end

	self.icon_hl_cache = {}
	self.icon = ""

	self.highlights = {
		leading = modules.highlight.create_component_highlight_group(
			{ fg = "#565f89", bg = "None" },
			"location_leading",
			self.options
		),
		current = modules.highlight.create_component_highlight_group(
			{ fg = "#c0caf5", bg = "None" },
			"location_leading",
			self.options
		),
	}

	vim.api.nvim_create_autocmd("BufEnter", {
		group = vim.api.nvim_create_augroup("pretty_path", {}),
		callback = function()
			if vim.bo.filetype == "" then
				return
			end
			for _, filetype in ipairs(self.options.exclude_filetypes) do
				if string.find(filetype, vim.bo.filetype) then
					return
				end
			end
			require("lualine").refresh({
				place = { "winbar" },
			})
		end,
	})
end

---@param path string
local function cwd_context(path)
	path = path:gsub("/$", "")
	local cwd_parent = vim.fn.fnamemodify(vim.fn.getcwd():gsub("/$", ""), ":h")
	if path == cwd_parent then
		return cwd_parent
	else
		path = string.gsub(path, "^" .. cwd_parent, "")

		return path
	end
end

local function get_oil_path()
	return require("oil").get_current_dir() or ""
end

function component:update_status()
	if vim.bo.filetype == "" then
		return ""
	end
	for _, filetype in ipairs(self.options.exclude_filetypes) do
		if string.find(filetype, vim.bo.filetype) then
			return ""
		end
	end

	self:update_icon()
	local path = ""
	if vim.bo.filetype == "oil" then
		path = cwd_context(get_oil_path())
	else
		path = cwd_context(vim.fn.expand("%:p"))
	end

	local path_split = vim.split(path, "/", { trimempty = true })
	if #path_split > 4 then
		path_split = { path_split[1], "...", path_split[#path_split - 1], path_split[#path_split] }
	end

	local status = ""

	if vim.bo.modified then
		status = status .. " " .. self.options.symbols.modified
	end
	if vim.bo.modifiable == false or vim.bo.readonly then
		status = status .. " " .. self.options.symbols.readonly
	end

	path_split[#path_split] = self.icon
		.. modules.highlight.component_format_highlight(self.highlights.current)
		.. path_split[#path_split]
		.. status

	return modules.highlight.component_format_highlight(self.highlights.leading)
		.. table.concat(path_split, " " .. self.options.symbols.separator .. " ")
end

function component:update_icon()
	if vim.bo.filetype == "" then
		return ""
	end
	for _, filetype in ipairs(self.options.exclude_filetypes) do
		if string.find(filetype, vim.bo.filetype) then
			return ""
		end
	end
	if vim.bo.filetype == "oil" then
		self.icon = ""
		return
	end
	local icon, icon_highlight_group
	local ok, devicons = pcall(require, "nvim-web-devicons")
	if ok then
		icon, icon_highlight_group = devicons.get_icon(vim.fn.expand("%:t"))
		if icon == nil then
			icon, icon_highlight_group = devicons.get_icon_by_filetype(vim.bo.filetype)
		end

		if icon == nil and icon_highlight_group == nil then
			self.icon = ""
			return
		end
		if icon then
			icon = icon .. " "
		end
		local highlight_color = modules.utils.extract_highlight_colors(icon_highlight_group, "fg")
		if highlight_color then
			local default_highlight = self:get_default_hl()
			local icon_highlight = self.icon_hl_cache[highlight_color]
			if not icon_highlight or not modules.highlight.highlight_exists(icon_highlight.name .. "_normal") then
				icon_highlight = self:create_hl({ fg = highlight_color }, icon_highlight_group)
				self.icon_hl_cache[highlight_color] = icon_highlight
			end

			icon = self:format_hl(icon_highlight) .. icon .. default_highlight
		end
	else
		ok = vim.fn.exists("*WebDevIconsGetFileTypeSymbol")
		if ok ~= 0 then
			icon = vim.fn.WebDevIconsGetFileTypeSymbol()
			if icon then
				icon = icon .. " "
			end
		end
	end

	if not icon then
		self.icon = ""
		return
	end

	self.icon = icon
end

return component
