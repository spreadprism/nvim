# nvim-surround keymaps (v4)

Repo: https://github.com/kylechui/nvim-surround — "Surround selections, stylishly".
Requires Neovim 0.8+.

## IMPORTANT: v4 keymap change

As of **v4**, keymaps are **no longer set up via `setup()`**. Passing
`keymaps` to `setup()` errors. You bind the `<Plug>` mappings yourself (or let
the plugin's default mappings run). Disable defaults with:

- `vim.g.nvim_surround_no_mappings = true` (all)
- `vim.g.nvim_surround_no_normal_mappings`
- `vim.g.nvim_surround_no_visual_mappings`
- `vim.g.nvim_surround_no_insert_mappings`

## Default keymaps and their `<Plug>` targets

### Insert mode (`i`)
| Key      | Plug                                  |
| -------- | ------------------------------------- |
| `<C-g>s` | `<Plug>(nvim-surround-insert)`        |
| `<C-g>S` | `<Plug>(nvim-surround-insert-line)`   |

### Normal mode (`n`)
| Key   | Plug                                     | Action |
| ----- | ---------------------------------------- | ------ |
| `ys`  | `<Plug>(nvim-surround-normal)`           | add around motion |
| `yss` | `<Plug>(nvim-surround-normal-cur)`       | add around current line |
| `yS`  | `<Plug>(nvim-surround-normal-line)`      | add around motion, on new lines |
| `ySS` | `<Plug>(nvim-surround-normal-cur-line)`  | add around current line, on new lines |
| `ds`  | `<Plug>(nvim-surround-delete)`           | delete pair |
| `cs`  | `<Plug>(nvim-surround-change)`           | change pair |
| `cS`  | `<Plug>(nvim-surround-change-line)`      | change pair, new lines |

### Visual / select mode (`x`)  ← for surrounding a selection
| Key  | Plug                                  | Action |
| ---- | ------------------------------------- | ------ |
| `S`  | `<Plug>(nvim-surround-visual)`        | surround the visual selection |
| `gS` | `<Plug>(nvim-surround-visual-line)`   | surround the visual selection, on new lines |

**To surround a VISUAL SELECTION, map mode `"x"` to
`<Plug>(nvim-surround-visual)`.** Mapping it in normal mode (`"n"`) does
nothing for selections.

## Core operations (usage)

- Add:    `ys{motion}{char}`   e.g. `ysiw)` -> `(word)`
- Delete: `ds{char}`           e.g. `ds]`
- Change: `cs{target}{repl}`   e.g. `cs'"` -> swaps `'` to `"`
- Opening delimiter `(` adds inner spaces; closing `)` does not.
- `t`/`T` = HTML tags, `f` = function call, `q` alias = `` `,',\" ``.
