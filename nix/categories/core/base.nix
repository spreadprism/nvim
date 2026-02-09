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
      hop
      blink-compat
      blink-cmp-git
      blink-cmp-conventional-commits
      tabout
      nvim-surround
      mini-ai
      mini-move
      nvim-treesitter-endwise
      nvim-treesitter-textobjects
      treesitter-context
    ]
    ++ (with vim_pkgs; [
      pkgs.unstable.vimPlugins.blink-cmp
      pkgs.unstable.vimPlugins.blink-pairs
      pkgs.unstable.vimPlugins.blink-indent
      nvim-treesitter.withAllGrammars
    ]);
}
