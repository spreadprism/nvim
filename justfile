set quiet := true

hello:
  echo hello

update *target="":
  NIX_CONFIG="extra-access-tokens = github.com=$(gh auth token)" nix flake update {{target}}
