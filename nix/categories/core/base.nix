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
      plenary-nvim
    ]
    ++ (with nvim_pkgs; [
      tokyonight
      which-key
      oil
      oil-vcs
      lspconfig
    ]);

  optionalPlugins = with nvim_pkgs;
    [
      snacks
      tmux-navigation
      neogit
      gitsigns
      mini_diff
    ]
    ++ (with vim_pkgs; [
      nvim-treesitter.withAllGrammars
    ]);
}
