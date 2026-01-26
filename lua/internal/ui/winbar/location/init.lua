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

		local path = self.path
		local childs = {}
		while path ~= self.root and path ~= "" and path ~= "/" do
			local is_dir = vim.fn.isdirectory(path) == 1
			local element = {}
			if path == self.path then
				local icon, hl
				if is_dir then
					icon = self.symbols.directory
					hl = { link = "Directory" }
				else
					icon, hl = self.get_icon(self.path)
					if icon == nil then
						icon, hl = self.get_icon_filetype(self.ft)
					end
				end

				if icon then
					table.insert(element, {
						hl = hl,
						provider = icon .. " ",
					})
				end

				table.insert(element, {
					hl = { fg = colors.fg },
					provider = vim.fn.fnamemodify(path, ":t"),
				})
			else
				table.insert(element, {
					provider = self.symbols.directory .. " ",
				})
				table.insert(element, {
					provider = vim.fn.fnamemodify(path, ":t"),
				})
			end

			table.insert(childs, element)
			local new_path = vim.fn.fnamemodify(path, ":h")
			if new_path == path then
				break
			end
			path = new_path
		end

		local root_name

		if self.root == "/" then
			root_name = self.root
		elseif self.root == vim.env.HOME then
			root_name = "~"
		else
			root_name = vim.fn.fnamemodify(self.root, ":t")
		end

		table.insert(childs, {
			{
				provider = self.symbols.directory .. " ",
				hl = { link = "Directory" },
			},
			{
				provider = root_name,
			},
		})

		local separator = {
			provider = self.symbols.separator,
		}
		childs = vim.fn.reverse(childs)

		-- Insert separator between each element
		local result = {}
		for i, child in ipairs(childs) do
			table.insert(result, child)
			if i < #childs then
				table.insert(result, separator)
			end
		end

		self.child = self:new(result, 1)
	end,
	provider = function(self)
		return self.child:eval()
	end,
	hl = { fg = colors.comment },
	update = "BufEnter",
}
