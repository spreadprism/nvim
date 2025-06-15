return {
	["go.mod"] = {
		icon = "󰟓",
		color = "#EF3D7B",
		name = "gomod",
	},
	["go.sum"] = {
		icon = "󰟓",
		color = "#EF3D7B",
		name = "gosum",
	},
	["go.work"] = {
		icon = "󰟓",
		color = "#29BEB0",
		name = "gosum",
	},
	[".env"] = {
		icon = "",
		color = "#F5BB33",
		name = "env",
	},
	[".gitignore"] = {
		icon = "󰊢",
		color = "#E94D32",
		name = "gitignore",
	},
	["makefile"] = {
		icon = "󱁻",
		color = "#EF5350",
		name = "makefiler",
	},
	["vite.config.ts"] = {
		icon = "",
		color = "#FFAB00",
		name = "viteconfig",
	},
	["vitest.config.ts"] = {
		icon = "",
		color = "#729a1a",
		name = "vitest",
	},
	[".nvim.lua"] = {
		icon = "",
		color = "#84bd64",
		name = ".nvim.lua",
	},
	["pyproject.toml"] = {
		icon = "",
		color = "#407EB0",
		name = "pyproject",
	},
	["docker-compose.dev.yml"] = {
		icon = "󰡨",
		color = "#458EE6",
		name = "dockercomposedev",
	},
	[".gitkeep"] = {
		icon = "󰊢",
		color = "#E94D32",
		name = "gitkeep",
	},
	["sqlc.yml"] = {
		icon = "",
		color = "#17DAE0",
		name = "sqlc",
	},
	[".envrc"] = vim.tbl_extend("force", require("icons.extension")["env"], {
		name = "envrc",
	}),
	["justfile"] = {
		icon = "󰚩",
		color = "#8957E5",
		name = "justfile",
	},
}
