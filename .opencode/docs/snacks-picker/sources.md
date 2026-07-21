# Snacks Picker — Sources

Built-in sources (names). Call any as `Snacks.picker.<name>(opts?)`.

- General/UI: autocmds, cliphist, colorschemes, command_history, commands,
  help, highlights, icons, jumps, keymaps, lazy, man, marks, notifications,
  pickers, picker_actions, picker_format, picker_layouts, picker_preview,
  projects, registers, resume, scratch, search_history, select, spelling,
  tags, undo, zoxide
- Files/search: explorer, files, recent, smart, grep, grep_buffers,
  grep_word, lines, treesitter
- Buffers/lists: buffers, qflist, loclist, diagnostics, diagnostics_buffer
- Git: git_branches, git_diff, git_files, git_grep, git_log, git_log_file,
  git_log_line, git_stash, git_status
- GitHub: gh_actions, gh_diff, gh_issue, gh_labels, gh_pr, gh_reactions
- LSP: lsp_config, lsp_declarations, lsp_definitions, lsp_implementations,
  lsp_incoming_calls, lsp_outgoing_calls, lsp_references, lsp_symbols,
  lsp_type_definitions, lsp_workspace_symbols

## Selected default source configs

### files
```lua
{ finder = "files", format = "file", show_empty = true,
  hidden = false, ignored = false, follow = false, supports_live = true }
```

### grep
```lua
{ finder = "grep", regex = true, format = "file", show_empty = true,
  live = true, supports_live = true } -- live grep by default
```

### grep_word
```lua
{ finder = "grep", regex = false, args = { "--word-regexp" }, format = "file",
  search = function(picker) return picker:word() end,
  live = false, supports_live = true }
```

### lines
```lua
{ finder = "lines", format = "lines",
  layout = { preview = "main", preset = "ivy" },
  jump = { match = true }, main = { current = true },
  sort = { fields = { "score:desc", "idx" } } }
```

### lsp_symbols  (document symbols — NOT live by default)
```lua
{ finder = "lsp_symbols", format = "lsp_symbol", tree = true,
  filter = {
    default = { "Class","Constructor","Enum","Field","Function","Interface",
      "Method","Module","Namespace","Package","Property","Struct","Trait" },
    markdown = true, help = true,
    lua = { "Class","Constructor","Enum","Field","Function","Interface",
      "Method","Module","Namespace","Property","Struct","Trait" }, -- no Package
  } }
```
Extra fields: `tree`, `keep_parents`, `filter` (per-ft kind filter, `true`=all),
`workspace`.

### lsp_workspace_symbols  (live by default)
```lua
-- = lsp_symbols extended with:
{ workspace = true, tree = false, supports_live = true, live = true }
```

### buffers
```lua
{ finder = "buffers", format = "buffer", hidden = false, unloaded = true,
  current = true, sort_lastused = true,
  win = { input = { keys = { ["<c-x>"] = { "bufdelete", mode = {"n","i"} } } },
          list  = { keys = { ["dd"] = "bufdelete" } } } }
```

### recent
```lua
{ finder = "recent_files", format = "file",
  filter = { paths = {
    [vim.fn.stdpath("data")] = false,
    [vim.fn.stdpath("cache")] = false,
    [vim.fn.stdpath("state")] = false } } }
```
