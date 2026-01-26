--- A winbar component that shows the current file location in a breadcrumb style.

local function separate(self, elements)
	local separator = {
		provider = self.symbols.separator,
	}
	local result = {}
	for i, child in ipairs(elements) do
		table.insert(result, child)
		if i < #elements then
			table.insert(result, separator)
		end
	end

	return result
end

local function get_symbol_hl(self, path)
	if vim.fn.isdirectory(path) == 1 then
		return self.symbols.directory, { link = "Directory" }
	else
		local icon, hl = self.get_icon(path)
		if icon == nil then
			icon, hl = self.get_icon_filetype(vim.fn.fnamemodify(path, ":e"))
		end
		return icon, hl
	end
end

local function element(self, path)
	local icon, hl = get_symbol_hl(self, path)

	local element_name
	if path == self.root then
		if self.root == "/" then
			element_name = self.root
		elseif self.root == vim.env.HOME then
			element_name = "~"
		else
			element_name = vim.fn.fnamemodify(self.root, ":t")
		end
	else
		element_name = vim.fn.fnamemodify(path, ":t")
	end

	return {
		{
			hl = hl,
			provider = icon .. " ",
		},
		{
			hl = self.path == path and { fg = colors.fg } or nil,
			provider = element_name,
		},
	}
end

local function assemble_location(self)
	local elements = {}
	local path = self.path
	while path ~= self.root and path ~= "" and path ~= "/" do
		table.insert(elements, element(self, path))

		local new_path = vim.fn.fnamemodify(path, ":h")
		if new_path == path then
			break
		end
		path = new_path
	end

	table.insert(elements, element(self, self.root))
	elements = separate(self, elements)

	return vim.fn.reverse(elements)
end

return {
	static = {
		symbols = {
			separator = " ",
			crop = "...",
			directory = "",
		},
	},
	init = function(self)
		if self.ft == "oil" then
			self.path = require("oil").get_current_dir(self.buf) or ""
		else
			self.path = vim.api.nvim_buf_get_name(self.buf)
		end

		-- strip /
		self.path = self.path:gsub("/$", "")

		local cwd = vim.fn.getcwd(self.win)

		if vim.startswith(self.path, cwd) then
			self.root = cwd
		elseif vim.startswith(self.path, vim.env.HOME) then
			self.root = vim.env.HOME
		else
			self.root = "/"
		end

		local location = assemble_location(self)
		self.child = self:new(location, 1)
	end,
	provider = function(self)
		return self.child:eval()
	end,
	hl = { fg = colors.comment },
	update = "BufEnter",
}
