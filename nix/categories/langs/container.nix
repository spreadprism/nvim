{
  pkgs,
  nvim_pkgs,
  ...
}: {
  lspsAndRuntimeDeps = with pkgs; [
    dockerfile-language-server
    docker-language-server
    docker-compose-language-service
  ];
  optionalPlugins = with nvim_pkgs; [
  ];
}
