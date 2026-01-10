{
  pkgs,
  vim_pkgs,
  nvim_pkgs,
  ...
}: {
  lspsAndRuntimeDeps = with pkgs; [
    sqlite
  ];
  startupPlugins = with vim_pkgs;
    [
      lze
      lzextras
    ]
    ++ (with nvim_pkgs; [
      tokyonight
      which-key
      oil
    ]);

  optionalPlugins = with nvim_pkgs;
    [
      snacks
    ]
    ++ (with vim_pkgs; [
      nvim-treesitter.withAllGrammars
    ]);
}
