{
  pkgs,
  vim_pkgs,
  ...
}: let
in {
  lspsAndRuntimeDeps = with pkgs; [
    codelldb
    rustfmt
    rust-analyzer
    clippy
  ];
  optionalPlugins = with vim_pkgs; [
    neotest-rust
    (nvim-treesitter.withPlugins (
      plugins:
        with plugins; [
          rust
        ]
    ))
  ];
}
