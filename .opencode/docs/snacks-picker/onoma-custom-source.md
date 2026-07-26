# Onoma + custom snacks sources (learned building the `Symbols` picker)

Onoma source lives in the nix store (find it with
`find /nix/store -maxdepth 1 -type d -name '*onoma*'`), key files under
`lua/providers/snacks/{provider,finder,format}.lua`.

## How onoma registers its snacks picker
- `provider.setup(opts)` builds a Rust-bridge `resolver` + `watcher`
  (closure-captured), then registers:
  `Snacks.picker.sources.get_symbols = <snacks.picker.Config>`.
- Assigning to `Snacks.picker.sources.<name>` makes `Snacks.picker.<name>()`
  callable — sources added AFTER `Snacks.picker.config.setup()` are
  auto-wrapped (metatable in `snacks/picker/config/init.lua`).
- Its source config: `live = true`, function `finder` delegating to
  `providers.snacks.finder.get_symbols(resolver, _, ctx, opts)`, custom
  `format` (`lsp_symbol`), matcher fully disabled
  (`fuzzy=false, sort_empty=true`, resolver ranks via `score_add`),
  `sort.fields = {"score:desc"}`.
- The finder returns an async `function(cb)`: reads `ctx.filter.search`,
  streams `resolver:query(query, context)`, emits items with
  `{ text, name, kind, file, pos, end_pos, score_add = result.score }`.
- NOTE: onoma does NOT set `supports_live`, so `<C-g>` (toggle_live) is
  refused on the stock `get_symbols` source.

## Snacks internals worth remembering
- `toggle_live` (default `<c-g>` in input win) requires
  `picker.opts.supports_live`. When live: typing edits `filter.search`
  (sent to finder). When toggled off: typing edits `filter.pattern`
  (matcher). Both coexist → grep-style "search then refine".
- Matcher pattern field syntax: `field:pat` resolves `item[field]`
  (`file:lua$`, `kind:Method`). Works regardless of `fuzzy` opt. No globs —
  use fzf syntax (`$` suffix, `^` prefix, `'` exact, `!` inverse).
- Finder is called as `_find(picker.opts, ctx)` — first arg is OPTS, not
  the picker. `ctx` has `Ctx:clone()` and `ctx.filter:clone()` for safely
  overriding `filter.search` before delegating to a wrapped finder.
- Finder only re-runs when `filter.search` changes (`Finder:init`).

## lze hook ordering (this repo)
`lze.c.loader`: `before` → handler run_before → load → handler run_after →
spec `after`. The `setup` handler (calls `module.setup(opts)`) runs in
handler run_after, so a `plugin("x"):after(fn)` hook runs AFTER the
plugin's `setup(opts)` — safe place to build on what setup registered.

## More snacks internals (scope toggle work)
- `picker:find({ refresh = true })` forces a finder re-run even when
  `filter.search` is unchanged, and calls `update_titles()` which renders
  `picker.title` — so a custom action can flip a custom `picker.opts.<flag>`,
  set `picker.title`, and refresh.
- Custom opts (e.g. `workspace`) can live on the source config; the finder
  receives them as its first arg (`picker.opts`), and per-picker mutation
  is instance-local.
- Inside a picker the "current buffer" is the input buffer — the origin
  buffer is `ctx.filter.current_buf` (captured by `Filter.new`).
- Source-level `win.input.keys` override defaults; key notation is
  normalized via `Snacks.util.normkey` before merge (`<c-w>` == `<C-w>`).
- `M.pick` toggles: invoking a source while a picker with the same
  `opts.source` is open closes it instead.
- Onoma bridge context `file_path` is only a relevance hint — NO scoping
  in the bridge API; buffer scoping must filter emitted items by path.
- `snacks.picker.Filter.opts` (`buf`, `paths`, `cwd`) are only applied by
  finders that voluntarily call `ctx.filter:match(item)` — onoma's doesn't.

## The custom `Symbols` picker (bottom of lua/plugins/core/snacks.lua)
Registered in `plugin("onoma"):after()` as
`Snacks.picker.sources.symbols = vim.tbl_extend("force", {}, get_symbols, {...})`:
- `supports_live = true` → `<C-g>` refine like grep.
- Wrapper `finder`: parses `/<kind-prefix>` tokens anywhere in the live
  query (`/f map` == `map /function`), strips them from the search handed
  to onoma (via `ctx:clone()` + `filter:clone()`), and filters emitted
  items by case-insensitive kind prefix in the `cb` wrapper.
- Scopes: `workspace = false` default filters items to the origin buffer's
  file (normalized absolute compare, cwd-joins relative paths).
  `toggle_scope` action on `<c-w>` flips `picker.opts.workspace`, swaps
  `picker.title` (`Symbols` / `Symbols (workspace)`), refreshes.
- Invoked via `<M-s>` → `symbols()` (buffer) and `<M-S>` →
  `symbols({ workspace = true, title = "Symbols (workspace)" })`.
