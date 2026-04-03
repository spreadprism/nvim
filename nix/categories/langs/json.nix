{
  pkgs,
  nvim_pkgs,
  ...
}: {
  lspsAndRuntimeDeps = with pkgs; [
    vscode-json-languageserver
    prettierd
  ];
  optionalPlugins = with nvim_pkgs; [
  ];
}
