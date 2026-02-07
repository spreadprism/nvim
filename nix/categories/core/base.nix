{
  pkgs,
  vim_pkgs,
  nvim_pkgs,
  ...
}: {
  lspsAndRuntimeDeps = with pkgs; [
    sqlite
  ];
  startupPlugins = with vim_pkgs; [
    lze
    lzextras
    plenary-nvim
  ];

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
      hop
      blink-compat
      blink-cmp-git
      blink-cmp-conventional-commits
      tabout
      nvim-surround
      mini-ai
      mini-move
      mini-git
      blame
    ]
    ++ (with vim_pkgs; [
      pkgs.unstable.vimPlugins.blink-cmp
      pkgs.unstable.vimPlugins.blink-pairs
      pkgs.unstable.vimPlugins.blink-indent
      nvim-treesitter.withAllGrammars
    ]);
}
