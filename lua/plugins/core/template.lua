plugin("esqueleto"):triggerUIEnter():opts({
	directories = { TEMPLATES_PATH },
	wildcards = {
		lookup = {
			["dirname"] = function()
				return vim.fn.fnamemodify(vim.fn.expand("%:p:h"), ":t")
			end,
			["cwd"] = function()
				return cwd()
			end,
			["cwd-basename"] = function()
				return vim.fn.fnamemodify(cwd(), ":t")
			end,
			["gh-description"] = function()
				return exec('gh repo view --json description -t "{{ .description }}"')
			end,
		},
	},
})
