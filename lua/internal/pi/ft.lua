--- Filetypes used by PI's panels.
local M = {}

--- The prompt (input) buffer filetype.
---@type string
M.prompt = "pi-chat-prompt"

--- Filetypes that receive keymaps.
---@type string[]
M.keymap = {
	"pi-chat-prompt",
	"pi-chat-history",
}

--- Every filetype PI uses for its panels (`M.keymap` only lists the ones that
--- get keymaps).
---@type string[]
M.panels = vim.list_extend({ "pi-chat-attachments", "pi-dialog" }, M.keymap)

--- Treat the prompt/history buffers as markdown for treesitter.
function M.register_treesitter()
	vim.treesitter.language.register("markdown", "pi-chat-prompt")
	vim.treesitter.language.register("markdown", "pi-chat-history")
end

return M
