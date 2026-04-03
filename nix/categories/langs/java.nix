{
  pkgs,
  nvim_pkgs,
  ...
}: {
  lspsAndRuntimeDeps = with pkgs; [
    jdt-language-server
    java-debug
  ];
  optionalPlugins = with nvim_pkgs; [
    jdtls
  ];
}
