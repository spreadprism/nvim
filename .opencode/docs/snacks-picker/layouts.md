# Snacks Picker — Layouts

The `layout` field: a preset name (string), a full `layout.Config` table, or a
function `fun(source:string) -> config|string`.

## Built-in presets
bottom, default, dropdown, ivy, ivy_split, left, right, select, sidebar,
telescope, top, vertical, vscode

## layout.Config (verbatim)
```lua
---@class snacks.picker.layout.Config
---@field layout snacks.layout.Box
---@field reverse? boolean list reversed (bottom-up)
---@field fullscreen? boolean
---@field cycle? boolean
---@field preview? "main" show preview in the picker or the main window
---@field preset? string|fun(source:string):string
---@field hidden? ("input"|"preview"|"list")[] windows not shown on open
---@field auto_hide? ("input"|"preview"|"list")[] hide when not focused
---@field config? fun(layout:snacks.picker.layout.Config) customize resolved layout
```

## Global default (responsive preset)
```lua
layout = {
  cycle = true,
  preset = function()
    return vim.o.columns >= 120 and "default" or "vertical"
  end,
}
```

## Set a preset per source
```lua
-- under picker.sources.<name>
layout = { preview = "main", preset = "ivy" }
```
Or inline: `Snacks.picker.files({ layout = "ivy" })`.
Or globally: `picker.layout = { preset = "telescope" }`.

## In THIS repo
`lua/plugins/core/snacks.lua` sets presets per source under
`picker.sources`: files=select, grep=telescope, lines=ivy_split,
lsp_symbols=right, lsp_workspace_symbols=telescope.
