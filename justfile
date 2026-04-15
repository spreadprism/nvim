set quiet := true

update *target="":
  NIX_CONFIG="extra-access-tokens = github.com=$(gh auth token)" nix flake update {{target}}
