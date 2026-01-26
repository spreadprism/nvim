return {
	static = {
		symbols = {
			separator = " ",
			crop = "...",
			directory = " ",
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
		while path ~= self.root do
			local element = {}
			if path == self.path then
				local icon, hl = self.get_icon(self.path)
				if icon == nil then
					icon, hl = self.get_icon_filetype(self.ft)
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
					hl = { fg = colors.comment },
					provider = self.symbols.directory .. vim.fn.fnamemodify(path, ":t"),
				})
			end

			table.insert(childs, element)
			path = vim.fn.fnamemodify(path, ":h")
		end

		self.child = self:new(childs, 1)
	end,
	provider = function(self)
		return self.child:eval()
	end,
	update = "BufEnter",
}
