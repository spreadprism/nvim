{
  pkgs,
  nvim_pkgs,
  ...
}: {
  lspsAndRuntimeDeps = with pkgs; [
    codelldb
    rustfmt
    rust-analyzer
    clippy
  ];
  optionalPlugins = with nvim_pkgs; [
    rustaceanvim
  ];
}
