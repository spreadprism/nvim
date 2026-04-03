set quiet := true

update:
  NIX_CONFIG="extra-access-tokens = github.com=$(gh auth token)" nix flake update

update_plugins:
	NIX_CONFIG="extra-access-tokens = github.com=$(gh auth token)" nix flake update plugins
