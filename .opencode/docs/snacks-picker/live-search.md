# Snacks Picker — Live search

Live search re-runs the finder on every keystroke (server-side query) instead
of fuzzy-matching a static, already-fetched item list.

## Fields (snacks.picker.Config)
```lua
---@field live? boolean when true, typing will trigger live searches
---@field limit? number stop after N items (useful for live searches)
---@field limit_live? number stop after N items during live searches (perf)
```
- `live` (boolean): enables live mode. Unset at top level; set per source.
- `supports_live` (boolean): per-source flag saying the finder CAN run live.
  Not on the top-level Config class — declared in individual source defaults.
  Enables the `toggle_live` action (`<c-g>`).
- `limit`: unset by default.
- `limit_live`: global default `10000`.

## Which sources set them
- `live = true` (live by default): grep, grep_buffers, git_grep, gh_issue,
  gh_pr, lsp_workspace_symbols
- `live = false` (off but toggleable): grep_word
- `supports_live = true`: explorer, files, grep, grep_buffers, grep_word,
  git_grep, git_log, gh_issue, gh_pr, lsp_workspace_symbols

## Practical notes
- For live LSP symbol search use `lsp_workspace_symbols` (ships
  `supports_live=true, live=true`), NOT `lsp_symbols` (document symbols,
  a bounded per-buffer list, fuzzy-matched; no `supports_live` by default).
- To force `lsp_symbols` live: add `supports_live = true, live = true` under
  `picker.sources.lsp_symbols` — but live matters little on a bounded list.
- Toggle at runtime with the `toggle_live` action (default `<c-g>`).
