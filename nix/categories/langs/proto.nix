{
  pkgs,
  nvim_pkgs,
  ...
}: {
  lspsAndRuntimeDeps = with pkgs; [
    buf
  ];
  optionalPlugins = with nvim_pkgs; [
  ];
}
