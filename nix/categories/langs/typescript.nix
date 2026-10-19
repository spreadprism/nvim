{
  pkgs,
  nvim_pkgs,
  ...
}: {
  lspsAndRuntimeDeps = with pkgs; [
    vtsls
    typescript # tsc cli (v7 / tsgo, no tsserver.js)
    prettierd
    eslint_d
  ];
  optionalPlugins = with nvim_pkgs; [
  ];
}
