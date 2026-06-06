plugin("origami")
	:event("DeferredUIEnter")
	:before(function()
		vim.opt.foldlevel = 99
		vim.opt.foldlevelstart = 99

		vim.o.foldenable = true
		vim.o.foldcolumn = "1"
	end)
	:opts({
		foldtext = {
			lineCount = {
				template = "󰁂 %d",
				hlgroup = "TodoFgTODO",
			},
			gitsignsCount = false,
			diagnosticsCount = false,
		},
		autoFold = {
			enabled = false,
		},
		foldKeymaps = {
			setup = false,
		},
	})
