# lze Plugin Spec

`lze` (https://github.com/BirdeeHub/lze) is a lazy-loading library (not a
plugin manager). `require("lze").load(specs)` accepts a list of plugin specs.
Specs are treated as an ordered list; start plugins without priority load in
the order passed.

## Loading hooks

| Property     | Type                       | Description |
| ------------ | -------------------------- | ----------- |
| `[1]`        | string                     | REQUIRED. Plugin's name = packpath dir name (usually repo name). Not module name, not URL. |
| `enabled?`   | boolean or fun():boolean   | When false, or fn returns nil/false, plugin is NOT included in the spec. |
| `beforeAll?` | fun(lze.Plugin)            | Runs on `load(spec)` before any spec in that call is triggered (~ lazy.nvim `init`). |
| `before?`    | fun(lze.Plugin)            | Runs before a plugin is loaded. |
| `after?`     | fun(lze.Plugin)            | Runs after a plugin is loaded (~ lazy.nvim `config`). |
| `priority?`  | number                     | Only for START plugins in the same `load()` call. Default 50 (`vim.g.lze.default_priority`). |
| `load?`      | fun(string)                | Override `vim.g.lze.load(name)` (default `vim.cmd.packadd`). |
| `allow_again?`| boolean or fun():boolean  | Allow re-adding an already-loaded plugin (mostly for testing). |
| `lazy?`      | boolean                    | Set automatically by using a handler field; can set manually. |

## Lazy-load triggers (default handlers)

| Property      | Type | Description |
| ------------- | ---- | ----------- |
| `event?`      | string / {event,pattern} / string[] | Load on event, optional pattern e.g. `BufEnter *.lua`. |
| `cmd?`        | string / string[] | Load on user command. |
| `ft?`         | string / string[] | Load on filetype. |
| `keys?`       | string / string[] / lze.KeysSpec[] | Load on keymap (mode `n` default). |
| `colorscheme?`| string / string[] | Load on colorscheme. |
| `dep_of?`     | string / string[] | Load this BEFORE another named plugin (after that plugin's `before`). Reverse of lazy.nvim `dependencies`. |
| `on_plugin?`  | string / string[] | Load AFTER another plugin, before its `after` hook. |
| `on_require?` | string / string[] | Load when any submodule of the given top-level lua module is required. |

## Key semantics / gotchas

- Using ANY handler field (event/cmd/ft/keys/...) implicitly sets `lazy = true`.
- `enabled = false` (or fn -> false/nil) removes the plugin entirely; the
  function is evaluated at spec-registration time (during `load()`).
- `import` spec imports a SINGLE lua module (not a directory) that returns
  more specs. A function form can delay generation until after `enabled`.
- User event `DeferredUIEnter`: fired when `load()` is done and after
  `UIEnter` (~ lazy.nvim `VeryLazy`). Alias more via
  `require('lze').h.event.set_event_alias(name, spec?)`.
- `packadd` does NOT source `after/` dirs; override `load` for cmp sources etc.

## Config globals

```lua
vim.g.lze = {
  injects = {},              -- default field values injected before handlers
  load = vim.cmd.packadd,    -- fallback load fn
  verbose = true,            -- warn on dup/missing/empty
  default_priority = 50,
  without_default_handlers = false, -- must be set before require("lze")
}
```
