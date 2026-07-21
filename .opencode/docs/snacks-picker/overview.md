# Snacks Picker — Overview

Source: https://github.com/folke/snacks.nvim/blob/main/docs/picker.md

Modern fuzzy-finder for Neovim, part of `folke/snacks.nvim`. A built-in
replacement for telescope / fzf-lua / mini.pick, and a better `vim.ui.select`.

## Features
- 40+ built-in sources.
- Fast async fuzzy matcher supporting fzf search syntax
  (https://junegunn.github.io/fzf/search-syntax/).
- Field searches like `file:lua$ 'function`.
- `files`/`grep` accept extra opts inline: `foo -- -e=lua`.
- Treesitter highlighting where sensible.
- Multiple layouts (built on `Snacks.layout`) or custom.
- Simple API to build your own pickers.

## Requirements / deps
- Enabled via the `picker` opts table in Snacks setup.
- External CLIs used where relevant (auto-detected): `fd`/`rg`/`find`
  (files), `rg` (grep), `git`, `gh`, `delta` (optional diff previewer),
  `zoxide`.
- Optional `sqlite3` for `db`/frecency (`db.sqlite3_path`).

## Enable (lazy.nvim)
```lua
{
  "folke/snacks.nvim",
  ---@type snacks.Config
  opts = {
    picker = {
      -- config here, or empty for defaults
    }
  }
}
```

## API call convention
Every source `foo` is callable as `Snacks.picker.foo(opts?)`. Equivalent forms:
```lua
Snacks.picker.files(opts)
Snacks.picker.pick("files", opts)
Snacks.picker.pick({ source = "files", ... })
```
- `Snacks.picker()` — show the "picker of all pickers".
- `Snacks.picker.pick(source?, opts?)` — create a new picker.
- `Snacks.picker.get({source?, tab?})` — get active pickers.
- `Snacks.picker.resume(opts?)` — resume last picker.
- `Snacks.picker.select(...)` — the `vim.ui.select` implementation.
