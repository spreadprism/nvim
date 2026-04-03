{
  pkgs,
  nvim_pkgs,
  ...
}: {
  lspsAndRuntimeDeps = with pkgs; [
    just-lsp
  ];
  optionalPlugins = with nvim_pkgs; [
  ];
}
