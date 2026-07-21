# Snacks Picker — Config structure

Config lives under the top-level `picker` key. Top-level fields are defaults
for ALL pickers; per-source overrides go under `sources.<name>` (each a
`snacks.picker.Config` merged over that source's built-in defaults).

## snacks.picker.Config (verbatim)
```lua
---@class snacks.picker.Config
---@field multi? (string|snacks.picker.Config)[]
---@field source? string source name and config to use
---@field pattern? string|fun(picker:snacks.Picker):string pattern used to filter items by the matcher
---@field search? string|fun(picker:snacks.Picker):string search string used by finders
---@field cwd? string current working directory
---@field live? boolean when true, typing will trigger live searches
---@field limit? number when set, the finder will stop after finding this number of items. useful for live searches
---@field limit_live? number when set, the finder will stop after finding this number of items during live searches. useful for performance
---@field ui_select? boolean set `vim.ui.select` to a snacks picker
---@field filter? snacks.picker.filter.Config generic filter used by some finders
---@field items? snacks.picker.finder.Item[] items to show instead of using a finder
---@field format? string|snacks.picker.format|string format function or preset
---@field finder? string|snacks.picker.finder|snacks.picker.finder.multi finder function or preset
---@field preview? snacks.picker.preview|string preview function or preset
---@field matcher? snacks.picker.matcher.Config|{} matcher config
---@field sort? snacks.picker.sort|snacks.picker.sort.Config sort function or config
---@field transform? string|snacks.picker.transform transform/filter function
---@field win? snacks.picker.win.Config
---@field layout? snacks.picker.layout.Config|string|{}|fun(source:string):(snacks.picker.layout.Config|string)
---@field icons? snacks.picker.icons
---@field prompt? string prompt text / icon
---@field title? string defaults to a capitalized source name
---@field auto_close? boolean automatically close the picker when focusing another window (defaults to true)
---@field show_empty? boolean show the picker even when there are no items
---@field show_delay? number delay (in ms) to wait before showing the picker while no results yet
---@field focus? "input"|"list" where to focus when the picker is opened (defaults to "input")
---@field enter? boolean enter the picker when opening it
---@field toggles? table<string, string|false|snacks.picker.toggle>
---@field previewers? snacks.picker.previewers.Config|{}
---@field formatters? snacks.picker.formatters.Config|{}
---@field sources? snacks.picker.sources.Config|{}|table<string, snacks.picker.Config|{}>
---@field layouts? table<string, snacks.picker.layout.Config>
---@field actions? table<string, snacks.picker.Action.spec> actions used by keymaps
---@field confirm? snacks.picker.Action.spec shortcut for confirm action
---@field auto_confirm? boolean automatically confirm if there is only one item
---@field main? snacks.picker.main.Config main editor window config
---@field on_change? fun(picker:snacks.Picker, item?:snacks.picker.Item) called when the cursor changes
---@field on_show? fun(picker:snacks.Picker) called when the picker is shown
---@field on_close? fun(picker:snacks.Picker) called when the picker is closed
---@field jump? snacks.picker.jump.Config|{}
---@field config? fun(opts:snacks.picker.Config):snacks.picker.Config? custom config function
---@field db? snacks.picker.db.Config|{}
---@field debug? snacks.picker.debug|{}
```

## matcher defaults
```lua
matcher = {
  fuzzy = true,          -- use fuzzy matching
  smartcase = true,
  ignorecase = true,
  sort_empty = false,    -- sort results when the search string is empty
  filename_bonus = true, -- bonus for matching the file name (last path part)
  file_pos = true,       -- support `file:line:col` and `file:line`
  cwd_bonus = false,     -- bonus for files in cwd (perf cost)
  frecency = false,      -- frecency bonus
  history_bonus = false, -- weight chronological order
}
```
