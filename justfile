set quiet := true

# list available recipes
default:
  just --list

hello:
  echo hello

# run the whole suite (plenary busted, isolated from the user config)
# nvim_cmd: children must be spawned through the nixCats wrapper, otherwise
# they start without the nix packpath (no plenary, no lze)
test dir="tests":
  nvim --headless -u tests/minimal_init.lua \
    -c "PlenaryBustedDirectory {{ dir }} {minimal_init = 'tests/minimal_init.lua', nvim_cmd = 'nvim'}" \
    -c "qa!"

# run a single spec file, e.g. `just test_file tests/internal/fs_spec.lua`
test_file file:
  nvim --headless -u tests/minimal_init.lua \
    -c "PlenaryBustedFile {{ file }}" \
    -c "qa!"

# only the performance specs
bench:
  just test tests/bench

# per-filetype editing scenarios, profiled, against the REAL config
# wait: settle time in ms after open and after write (default 2000)
langs wait="2000" dir="tests/scenarios":
  NVIM_FT_WAIT_MS={{ wait }} nvim --headless -u tests/full_init.lua \
    -c "PlenaryBustedDirectory {{ dir }} {minimal_init = 'tests/full_init.lua', nvim_cmd = 'nvim', timeout = 900000, sequential = true}" \
    -c "qa!"

update *target="":
  NIX_CONFIG="extra-access-tokens = github.com=$(gh auth token)" nix flake update {{target}}

# refresh the plugin inputs declared in nix/plugins/flake.nix
update_plugins:
  just update plugins
