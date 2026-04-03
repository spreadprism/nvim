{
  pkgs,
  nvim_pkgs,
  ...
}: {
  lspsAndRuntimeDeps = with pkgs; [
    marksman
  ];
  optionalPlugins = with nvim_pkgs; [
    render-markdown
  ];
}
