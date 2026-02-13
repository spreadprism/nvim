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
    nvim-nio
  ];

  optionalPlugins = with nvim_pkgs; [
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
    conform
    lint
    osc52
    smart-paste
    treesj
    scrollbar
    undotree
    nvim-dap
    nvim-dap-ui
    nvim-dap-virtual-text
    copilot
    opencode
    todo-comments
    pkgs.unstable.vimPlugins.blink-cmp
    pkgs.unstable.vimPlugins.blink-pairs
    pkgs.unstable.vimPlugins.blink-indent
    pkgs.unstable.vimPlugins.nvim-treesitter.withAllGrammars
  ];
}
