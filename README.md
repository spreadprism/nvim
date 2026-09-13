# nvim

## Justfile

Repetitive commands live in the [`justfile`](./justfile) and are run with
[`just`](https://github.com/casey/just):

```sh
just <recipe> [args...]
```

`set quiet := true` at the top disables echoing each recipe line, so you only
see the command's own output.

### Recipes

| Recipe | Usage | What it does |
| --- | --- | --- |
| `default` | `just` | Lists every available recipe (runs when no recipe is given). |
| `hello` | `just hello` | Smoke test — prints `hello`. |
| `update` | `just update [target]` | Runs `nix flake update` with a GitHub token injected. |
| `update_plugins` | `just update_plugins` | Shorthand for `just update plugins`. |

### `just update`

```just
update *target="":
  NIX_CONFIG="extra-access-tokens = github.com=$(gh auth token)" nix flake update {{target}}
```

- `*target=""` is a variadic parameter defaulting to empty, so with no
  arguments the whole `flake.lock` is refreshed, and with arguments only the
  named flake inputs are.
- `NIX_CONFIG="extra-access-tokens = github.com=$(gh auth token)"` pulls a
  token from the `gh` CLI for that single invocation. This avoids GitHub API
  rate limits when resolving the many `github:` plugin inputs, and it requires
  `gh auth login` to have been done beforehand.

Examples:

```sh
# refresh every input in flake.lock
just update

# refresh a single input
just update nixCats

# refresh several inputs at once
just update nixpkgs neovim

# refresh the plugin inputs declared in nix/plugins/flake.nix
just update plugins
```

> Note: plugin sources live in their own flake at
> [`nix/plugins/flake.nix`](./nix/plugins/flake.nix). After changing them, run
> `just update_plugins` (alias for `just update plugins`) so the lock file in
> the root flake picks up the change.
