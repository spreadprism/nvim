# tests

[plenary.busted](https://github.com/nvim-lua/plenary.nvim) specs, same shape as
`crust.nvim/tests`.

```sh
just test                              # everything (minimal init)
just test tests/internal               # one directory
just test_file tests/internal/fs_spec.lua
just bench                             # only tests/bench
just langs                             # per-filetype scenarios, real config
just langs 500                         # ...with 500ms settle instead of 2000ms
just langs 2000 out/report.txt         # ...writing the summary elsewhere
```

Specs run in a headless nvim started with `-u tests/minimal_init.lua`, so the
user config never loads. The nixCats wrapper still puts the nix pack dir on
'packpath' (plenary, lze, and every plugin in `start/` are available), and the
working tree is *prepended* to 'runtimepath' so `require("internal.…")` picks up
the checkout instead of the built config in `/nix/store`.

## Layout

| path | contents |
| --- | --- |
| `tests/minimal_init.lua` | rtp/package.path setup, nixCats mock, plenary |
| `tests/full_init.lua` | same, but runs the real `init.lua` (plugins, langs, LSP) |
| `tests/helpers/bench.lua` | timing, budgets, scaling assertions |
| `tests/helpers/fixtures.lua` | temp dirs, files, buffers — `cleanup()` in `after_each` |
| `tests/helpers/scenario.lua` | profiled open/edit/save/revert sessions + report |
| `tests/internal/*_spec.lua` | unit specs for `lua/internal/` |
| `tests/bench/*_bench_spec.lua` | performance specs |
| `tests/scenarios/*_spec.lua` | full-config scenarios (`just langs`) |

`tests/` is on `package.path`, so helpers are plain requires:

```lua
local bench = require("helpers.bench")
local fixtures = require("helpers.fixtures")
```

## Performance specs

```lua
-- fails if the median call exceeds 2ms
bench.budget("find_up miss at depth 12", 2, function()
	fs.find_up("never-exists.toml", { path = start, stop = dir })
end)

-- or measure, print, and compare
local small = bench.measure("small input", fn)
local large = bench.measure("large input", fn)
bench.assert_scaling(small, large, 3)
```

`measure()` warms up (5 runs), collects garbage between samples, takes 30
samples and reports median/p95/min/max. Use `batch` for work that is too fast to
time once:

```lua
bench.budget("cheap call", 0.05, fn, { batch = 100, samples = 20 })
```

Rules of thumb:

- assert on the **median**, never the mean — a GC pause must not fail the suite;
- budgets catch order-of-magnitude regressions, not 10% drift, because the
  machine running the suite is not the machine the number was tuned on;
- `bench.FRAME_MS` (16ms) is the reference for anything synchronous on the UI
  path; a keystroke handler should stay well under half of it;
- prefer `assert_scaling` for anything whose input grows (files in a project,
  lines in a buffer, open buffers): the ratio is stable across machines.

## Filetype scenarios (`just langs`)

`tests/scenarios/filetypes_spec.lua` drives one real editing session per entry
in `lua/langs/`: open a file → settle 2s → append a line and `:write` → settle
2s → restore and `:write`. The snacks profiler runs for the duration of each
scenario, and the final spec prints a combined report: per-filetype phase
timings with the attached LSP clients, then the five slowest traced functions
per scenario.

The same text is written to `report.txt` (`$NVIM_FT_REPORT`, the recipe's
second argument). It is written only once the run reaches the reporting spec,
so a crashed or interrupted run leaves the previous report untouched.

Add a language by appending to the `langs` table — `label`, expected
`filetype`, `file`, `lines`, the `insert` line, and any `extra` sibling files
its server needs to find a project root (`go.mod`, `Cargo.toml`, `Chart.yaml`,
…). The workspace is a throwaway tempdir with a `.git` in it and is deleted
afterwards, along with the buffers and the LSP clients it started.

Gotchas baked into the harness:

- headless nvim never fires `UIEnter`, so `scenario.boot()` fires it plus
  `User DeferredUIEnter` — without it, lze leaves most plugins unloaded;
- plenary spawns children with `v:progpath`, which is the *unwrapped* nvim and
  has no nix packpath, hence `nvim_cmd = 'nvim'` in the recipes;
- `scenario.PROFILER_OPTS.filter_mod` excludes conform and gitsigns: snacks'
  tracer truncates `nil, value` returns, which breaks them outright while
  traced (conform throws on every `:write`);
- specs must not live in `tests/langs/`: the config's own loader globs
  `*/langs/*.lua` on the runtimepath and would try to load them as language
  modules.
