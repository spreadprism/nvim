{
  pkgs,
  nvim_pkgs,
  ...
}: {
  lspsAndRuntimeDeps = with pkgs; [
    unstable.marksman
  ];
  optionalPlugins = with nvim_pkgs; [
    render-markdown
  ];
}
