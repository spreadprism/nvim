set quiet := true

# list available recipes
default:
  just --list

hello:
  echo hello

update *target="":
  NIX_CONFIG="extra-access-tokens = github.com=$(gh auth token)" nix flake update {{target}}

# refresh the plugin inputs declared in nix/plugins/flake.nix
update_plugins:
  just update plugins
