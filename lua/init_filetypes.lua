vim.filetype.add({
	extension = {
		tf = "terraform",
	},
	filename = {
		[".env"] = "dotenv",
		[".envrc"] = "dotenv",
	},
})
