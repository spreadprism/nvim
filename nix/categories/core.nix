{
  vim_pkgs,
  nvim_pkgs,
  ...
}: {
  startupPlugins = with vim_pkgs; [
    lze
    lzextras
  ];

  optionalPlugins = with nvim_pkgs; [
    snacks
  ];
}
