local M = {}

M.file_history_keys = {
	["gd"] = function()
		require("diffview.actions").goto_file()
		vim.cmd("tabclose #")
	end,
	["<C-q>"] = function()
		vim.cmd("tabclose")
	end,
	["<leader>gh"] = function()
		vim.cmd("tabclose")
	end,
	{
		"n",
		"j",
		function()
			require("diffview.actions").next_entry()
		end,
		{ desc = "Bring the cursor to the next file entry" },
	},
	{
		"n",
		"k",
		function()
			require("diffview.actions").prev_entry()
		end,
		{ desc = "Bring the cursor to the previous file entry" },
	},
	{
		"n",
		"<cr>",
		function()
			require("diffview.actions").select_entry()
		end,
		{ desc = "Open the diff for the selected entry" },
	},
}

M.file_panel_keys = {
	["gd"] = function()
		require("diffview.actions").goto_file()
		vim.cmd("tabclose #")
	end,
	["<C-q>"] = function()
		vim.cmd("tabclose")
	end,
	["<leader>gd"] = function()
		vim.cmd("tabclose")
	end,
	{
		"n",
		"j",
		function()
			require("diffview.actions").next_entry()
		end,
		{ desc = "Bring the cursor to the next file entry" },
	},
	{
		"n",
		"k",
		function()
			require("diffview.actions").prev_entry()
		end,
		{ desc = "Bring the cursor to the previous file entry" },
	},
	{
		"n",
		"<cr>",
		function()
			require("diffview.actions").select_entry()
		end,
		{ desc = "Open the diff for the selected entry" },
	},
}

M.view_keys = {
	["<C-q>"] = function()
		vim.cmd("tabclose")
	end,
	["<leader>gd"] = function()
		vim.cmd("tabclose")
	end,
	{
		"n",
		"<M-l>",
		function()
			require("diffview.actions").prev_conflict()
		end,
		{ desc = "In the merge-tool: jump to the previous conflict" },
	},
	{
		"n",
		"<M-h>",
		function()
			require("diffview.actions").next_conflict()
		end,
		{ desc = "In the merge-tool: jump to the next conflict" },
	},
	{
		"n",
		"<M-j>",
		function()
			require("diffview.actions").select_next_entry()
		end,
		{ desc = "Open the diff for the next file" },
	},
	{
		"n",
		"<M-k>",
		function()
			require("diffview.actions").select_prev_entry()
		end,
		{ desc = "Open the diff for the previous file" },
	},
	{
		"n",
		"<leader>e",
		function()
			require("diffview.actions").toggle_files()
		end,
		{ desc = "Toggle the file panel." },
	},
	{
		"n",
		"<leader>co",
		function()
			require("diffview.actions").conflict_choose("ours")
		end,
		{ desc = "Choose the OURS version of a conflict" },
	},
	{
		"n",
		"<leader>ct",
		function()
			require("diffview.actions").conflict_choose("theirs")
		end,
		{ desc = "Choose the THEIRS version of a conflict" },
	},
	{
		"n",
		"<leader>cb",
		function()
			require("diffview.actions").conflict_choose("base")
		end,
		{ desc = "Choose the BASE version of a conflict" },
	},
	{
		"n",
		"<leader>ca",
		function()
			require("diffview.actions").conflict_choose("all")
		end,
		{ desc = "Choose all the versions of a conflict" },
	},
	{
		"n",
		"dx",
		function()
			require("diffview.actions").conflict_choose("none")
		end,
		{ desc = "Delete the conflict region" },
	},
	{
		"n",
		"<leader>cO",
		function()
			require("diffview.actions").conflict_choose_all("ours")
		end,
		{ desc = "Choose the OURS version of a conflict for the whole file" },
	},
	{
		"n",
		"<leader>cT",
		function()
			require("diffview.actions").conflict_choose_all("theirs")
		end,
		{ desc = "Choose the THEIRS version of a conflict for the whole file" },
	},
	{
		"n",
		"<leader>cB",
		function()
			require("diffview.actions").conflict_choose_all("base")
		end,
		{ desc = "Choose the BASE version of a conflict for the whole file" },
	},
	{
		"n",
		"<leader>cA",
		function()
			require("diffview.actions").conflict_choose_all("all")
		end,
		{ desc = "Choose all the versions of a conflict for the whole file" },
	},
	{
		"n",
		"dX",
		function()
			require("diffview.actions").conflict_choose_all("none")
		end,
		{ desc = "Delete the conflict region for the whole file" },
	},
}

return M
