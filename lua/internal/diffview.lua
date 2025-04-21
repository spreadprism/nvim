local M = {}

local common = {
	{ "n", "<C-q>", kcmd("tabclose"), { desc = "close" } },
	{ "n", "<Down>", klazy("diffview.actions").select_next_entry(), { desc = "select next entry" } },
	{ "n", "<Up>", klazy("diffview.actions").select_prev_entry(), { desc = "select previous entry" } },
	{ "n", "<localleader>e", klazy("diffview.actions").toggle_files(), { desc = "toggle files" } },
}
M.file_history_keys = {}
M.file_panel_keys = {
	{ "n", "s", klazy("diffview.actions").toggle_stage_entry(), { desc = "toggle stage" } },
	{ "n", "u", klazy("diffview.actions").toggle_stage_entry(), { desc = "toggle stage" } },
	{ "n", "S", klazy("diffview.actions").stage_all(), { desc = "stage all" } },
	{ "n", "U", klazy("diffview.actions").unstage_all(), { desc = "unstage all" } },
	{ "n", "<cr>", klazy("diffview.actions").select_entry(), { desc = "select entry" } },
	{ "n", "<Tab>", klazy("diffview.actions").select_entry(), { desc = "select entry" } },
}
M.view_keys = {
	{ "n", "<Down>", klazy("diffview.actions").select_next_entry(), { desc = "select next entry" } },
	{ "n", "<Up>", klazy("diffview.actions").select_prev_entry(), { desc = "select previous entry" } },
	{ "n", "<Right>", klazy("diffview.actions").next_conflict(), { desc = "next conflict" } },
	{ "n", "<Left>", klazy("diffview.actions").prev_conflict(), { desc = "previous conflict" } },
	-- { "n", "co", klazy("diffview.actions").conflict_choose("ours"), { desc = "choose ours" } },
	-- { "n", "cO", klazy("diffview.actions").conflict_choose_all("ours"), { desc = "choose all ours" } },
	-- { "n", "ct", klazy("diffview.actions").conflict_choose("theirs"), { desc = "choose theirs" } },
	-- { "n", "cT", klazy("diffview.actions").conflict_choose_all("theirs"), { desc = "choose all theirs" } },
	-- { "n", "cb", klazy("diffview.actions").conflict_choose("base"), { desc = "choose base" } },
	-- { "n", "cB", klazy("diffview.actions").conflict_choose_all("base"), { desc = "choose all base" } },
	-- { "n", "cx", klazy("diffview.actions").conflict_choose("none"), { desc = "choose none" } },
	-- { "n", "cX", klazy("diffview.actions").conflict_choose_all("none"), { desc = "choose all none" } },
	-- { "n", "s", klazy("diffview.actions").toggle_stage_entry(), { desc = "toggle stage" } },
	-- { "n", "u", klazy("diffview.actions").toggle_stage_entry(), { desc = "toggle stage" } },
	-- { "n", "S", klazy("diffview.actions").stage_all(), { desc = "stage all" } },
	-- { "n", "U", klazy("diffview.actions").unstage_all(), { desc = "unstage all" } },
}

vim.list_extend(M.file_history_keys, common)
vim.list_extend(M.file_panel_keys, common)
vim.list_extend(M.view_keys, common)

return M
