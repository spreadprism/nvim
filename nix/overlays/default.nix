# This file defines overlays
{...}: {
  codelldb = import ./codelldb.nix;
  java-debug = import ./java.nix;
  commit-lsp = import ./commit-lsp.nix;
}
