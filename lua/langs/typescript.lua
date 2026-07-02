local ft = { "typescript", "javascript" }

plugin("typescript-tools")
	:event("DeferredUIEnter")
	:opts({
		settings = {
			publish_diagnostic_on = "change",
		},
	})
	:keymaps({
		k:map("n", "<localleader>o", k:cmd("TSToolsOrganizeImports"), "organize imports"):ft(ft),
		k:map("n", "<localleader>a", k:cmd("TSToolsAddMissingImports"), "add missing imports"):ft(ft),
		k:map("n", "<localleader>f", k:cmd("TSToolsFixAll"), "fix all"):ft(ft),
	})

formatter(ft, "prettierd")
linter(ft, "eslint_d")
