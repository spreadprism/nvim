{
  vim_pkgs,
  nvim_pkgs,
  ...
}: {
  startupPlugins = with vim_pkgs;
    [
      transparent-nvim
    ]
    ++ (with nvim_pkgs; [
      tokyonight
    ]);
}
