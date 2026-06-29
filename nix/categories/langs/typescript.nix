{
  pkgs,
  nvim_pkgs,
  ...
}: {
  lspsAndRuntimeDeps = with pkgs; [
    typescript
  ];
  optionalPlugins = with nvim_pkgs; [
    typescript-tools
  ];
}
