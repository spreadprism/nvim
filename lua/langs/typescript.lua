plugin("typescript-tools"):event("DeferredUIEnter"):opts({
	settings = {
		publish_diagnostic_on = "change",
	},
})

local ft = { "typescript", "javascript" }

formatter(ft, "prettierd")
linter(ft, "eslint_d")
