local old_set = vim.diagnostic.set
---@diagnostic disable-next-line: duplicate-set-field
vim.diagnostic.set = function(namespace, bufnr, diagnostics, opts)
	local filter = function(diagnostics)
		local unique = {}

		---@param diagnostic vim.Diagnostic
		return vim.tbl_filter(function(diagnostic)
			local key = string.format(
				"%d_%s_%s_%s_%d_%d_%d_%d",
				diagnostic.bufnr or 0,
				diagnostic.code or "",
				diagnostic.message,
				diagnostic.source or "unknown",
				diagnostic.col,
				diagnostic.end_col or 0,
				diagnostic.lnum,
				diagnostic.end_lnum or 0
			)
			if unique[key] then
				return false
			else
				unique[key] = true
				return true
			end
		end, diagnostics)
	end
	old_set(namespace, bufnr, filter(diagnostics), opts)
end
