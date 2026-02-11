return {
	init = function(self)
		self.clients = vim.lsp.get_clients({ bufnr = self.bufnr })
	end,
	condition = function(self)
		return #vim.tbl_filter(
			function(display)
				return display
			end,
			vim.tbl_map(function(client)
				if require("internal.loader.lsp").display(client, self.bufnr) then
					return client.name
				else
					return nil
				end
			end, vim.lsp.get_clients({ bufnr = self.bufnr }))
		) > 0
	end,
	provider = function(self)
		return table.concat(
			vim.tbl_filter(
				function(display)
					return display
				end,
				vim.tbl_map(function(client)
					if require("internal.loader.lsp").display(client, self.bufnr) then
						return client.name
					else
						return nil
					end
				end, self.clients)
			),
			", "
		)
	end,
	hl = { fg = colors.fg_dark },
	{ provider = " | " },
}
