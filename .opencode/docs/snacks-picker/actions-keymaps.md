# Snacks Picker — Actions & keymaps

Keymaps are per window under `win.<input|list|preview>.keys`. Actions used by
keymaps live under `actions` (`table<string, Action.spec>`).

## win.Config
```lua
---@class snacks.picker.win.Config
---@field input? snacks.win.Config|{}
---@field list? snacks.win.Config|{}
---@field preview? snacks.win.Config|{}
```

## Key mapping entry shapes
- Action name string: `["/"] = "toggle_focus"`
- Table with modifiers: `["<CR>"] = { "confirm", mode = { "n", "i" } }`
- Action sequence: `["<S-CR>"] = { { "pick_win", "jump" }, mode = {"n","i"} }`
- Expr: `["<C-w>"] = { "<c-s-w>", mode = { "i" }, expr = true, desc = "delete word" }`

## Notable default actions
confirm, cancel, close, toggle_focus, toggle_live, toggle_preview,
toggle_maximize, toggle_hidden, toggle_ignored, toggle_follow,
list_down/up, list_scroll_down/up/center/top/bottom,
preview_scroll_down/up/left/right, select_all, select_and_next/prev,
history_back/forward, qflist/qflist_all, loclist, edit_split/edit_vsplit/tab,
cycle_win, focus_input/list/preview, pick_win, jump, inspect,
layout_left/right/top/bottom, insert_cword/cWORD/file/line/filename,
git_* (checkout, stage, branch_add, ...), bufdelete, yank, search, cd/lcd/tcd.

## Example: custom keys + action (flash)
```lua
picker = {
  win = { input = { keys = {
    ["<a-s>"] = { "flash", mode = { "n", "i" } },
    ["s"]     = { "flash" },
  } } },
  actions = {
    flash = function(picker)
      require("flash").jump({ --[[ ... ]] })
    end,
  },
}
```

## Common tweak: Esc closes instead of normal mode
```lua
["<Esc>"] = { "close", mode = { "n", "i" } }
```

## In THIS repo
`snacks.lua` sets `win.input.keys["<S-CR>"] = { "tab", mode = {"n","i"} }`.
