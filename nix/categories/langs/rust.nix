{
  pkgs,
  nvim_pkgs,
  ...
}: {
  lspsAndRuntimeDeps = with pkgs; [
    codelldb
  ];
  optionalPlugins = with nvim_pkgs; [
  ];
}
