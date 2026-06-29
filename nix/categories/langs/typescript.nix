{
  pkgs,
  nvim_pkgs,
  ...
}: {
  lspsAndRuntimeDeps = with pkgs; [
    typescript
    prettierd
    eslint_d
  ];
  optionalPlugins = with nvim_pkgs; [
    typescript-tools
  ];
}
