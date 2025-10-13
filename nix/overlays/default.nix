{inputs, ...}: [
  (import ./codelldb.nix)
  (import ./java.nix)
  (import ./unstable.nix {inherit inputs;})
]
