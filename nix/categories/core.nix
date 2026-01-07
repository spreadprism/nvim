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
      tokyonight
      which-key
    ]);

  optionalPlugins = with nvim_pkgs; [
    snacks
  ];
}
