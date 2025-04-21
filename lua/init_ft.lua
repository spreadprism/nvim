vim.filetype.add({
	extension = {
		tf = "terraform",
		http = "http",
		env = "dotenv",
	},
	filename = {
		[".envrc"] = "dotenv",
	},
	pattern = {
		["%.env%.[%w_.-]+"] = "dotenv",
	},
})
