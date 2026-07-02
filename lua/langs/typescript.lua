local ft = { "typescript", "javascript" }

plugin("typescript-tools")
	:event("DeferredUIEnter")
	:opts({
		settings = {
			publish_diagnostic_on = "change",
		},
	})
	:keymaps({
		k:group("typescript", "<localleader>", {
			k:map("n", "o", k:cmd("TSToolsOrganizeImports"), "organize imports"),
			k:map("n", "a", k:cmd("TSToolsAddMissingImports"), "add missing imports"),
			k:map("n", "f", k:cmd("TSToolsFixAll"), "fix all"),
		}):ft(ft),
	})

formatter(ft, "prettierd")
linter(ft, "eslint_d")
