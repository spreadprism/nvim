{
  pkgs,
  nvim_pkgs,
  ...
}: {
  lspsAndRuntimeDeps = with pkgs; [
    tofu-ls
    tflint
  ];
  optionalPlugins = with nvim_pkgs; [
  ];
}
