# LuaSnip Feature Notes

Research notes on three LuaSnip capabilities.
Repo: https://github.com/L3MON4D3/LuaSnip · Docs: [DOC.md](https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md)

## 1. Expand a snippet on file enter — ✅ Yes

Programmatically expand a snippet from a `BufEnter`/`FileType` autocmd using
`ls.snip_expand()`. This inserts the snippet at the cursor without the user
typing a trigger.

```lua
local ls = require("luasnip")
local s, t, i = ls.snippet, ls.text_node, ls.insert_node

local snippets = {
  header = s("hdr", { t("expanded on enter"), i(1, "placeholder") }),
}

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*.lua",
  callback = function()
    ls.snip_expand(vim.deepcopy(snippets.header))
  end,
})
```

Note: `snippetType = "autosnippet"` + `enable_autosnippets = true` gives
auto-expand-on-type, but that still requires typing the trigger. For true
file-enter expansion use the `snip_expand()` approach above.

Sources: DOC.md, https://github.com/L3MON4D3/LuaSnip/discussions/389

## 2. Snippets hidden from autocompletion but still expandable — ✅ Yes

Two options, both keep the snippet expandable via trigger / `snip_expand()`:

- **`hidden = true`** — permanent hint to hide from the completion menu.
- **`show_condition = fn(line_to_cursor) -> bool`** — dynamic; return `false`
  to hide it from cmp in the current context.

```lua
ls.add_snippets("lua", {
  s({ trig = "secret", hidden = true }, { t("hidden from cmp, still expandable") }),

  s({
    trig = "conditional",
    show_condition = function(line_to_cursor)
      return line_to_cursor:match("^%s*%-%-") ~= nil
    end,
  }, { t("only shows in cmp after a comment") }),
})
```

`cmp_luasnip` honors `show_condition` when its `use_show_condition = true`
(the default). This is distinct from `condition`, which actually blocks
*expansion* — not what you want for merely hiding from completion.

Sources: DOC.md, https://github.com/saadparwaiz1/cmp_luasnip

## 3. Apply a snippet to a file not open in a buffer — ⚠️ Not directly

Expansion is tied to a **live, current buffer**. `ls.snip_expand()` requires
the target buffer to be the current active buffer with a real cursor position;
it writes via buffer APIs (`nvim_buf_set_text`, extmarks, cursor tracking), so
it cannot operate on a file sitting on disk with no buffer. The maintainer
confirmed a buffer only has focus between `BufEnter`/`BufLeave`.

### Option A — Hidden scratch buffer, expand, write back

Full expansion, but the interactive parts (jumps, choice/dynamic nodes) need a
real editing session, so headless output is effectively the default placeholder
text. Also, the buffer must be *current* during expansion, so it momentarily
swaps the active buffer (not truly "without opening").

```lua
local ls = require("luasnip")

local buf = vim.api.nvim_create_buf(true, false)
vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.fn.readfile(path))
vim.api.nvim_set_current_buf(buf)          -- MUST be current
vim.api.nvim_win_set_cursor(0, {1, 0})

ls.snip_expand(snippet)

vim.fn.writefile(vim.api.nvim_buf_get_lines(buf, 0, -1, false), path)
vim.api.nvim_buf_delete(buf, { force = true })
```

### Option B — Static text only, no buffer

`snippet:get_docstring()` returns a text representation without any buffer, but
it's the *docstring* form (placeholders shown as `${1:default}`, no
function/dynamic node evaluation) — meant for previews, not real output.

### Bottom line

| Goal | Approach |
|------|----------|
| Real expanded content written to disk | Option A — load into a buffer (must be current), expand, write back |
| No buffer at all | Option B — `get_docstring()`, static/placeholder text only |

There is **no supported API to render a fully-expanded snippet to a string**
for a file you never open. The cleanest supported pattern is to open the new
file normally on `BufNewFile`/`BufReadPost` and expand into that live buffer
(skeleton/template flow).

Sources: DOC.md, https://github.com/L3MON4D3/LuaSnip/discussions/970,
https://vi.stackexchange.com/questions/37604/nvim-how-do-i-insert-a-luasnip-for-bufnewfile-skel
