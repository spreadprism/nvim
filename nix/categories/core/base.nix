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
      ]);

  optionalPlugins = with nvim_pkgs;
    [
      which-key
      lspconfig
      oil
      oil-vcs
      tokyonight
      snacks
      tmux-navigation
      neogit
      gitsigns
      mini_diff
      hop
    ]
    ++ (with vim_pkgs; [
      nvim-treesitter.withAllGrammars
    ]);
}
