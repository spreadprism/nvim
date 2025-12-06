{
  vim_pkgs,
  nvim_pkgs,
  ...
}: {
  startupPlugins = with vim_pkgs;
    [
      lze
      lzextras
    ]
    ++ (with nvim_pkgs; [
      snacks
    ]);
}
