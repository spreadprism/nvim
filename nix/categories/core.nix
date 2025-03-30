{ pkgs, ...}:
let
  neovimPlugins = pkgs.neovimPlugins;
  vimPlugins = pkgs.vimPlugins;
in
let
  # this section is for dependencies that should be available
  # at RUN TIME for plugins. Will be available to PATH within neovim terminal
  runtime = with pkgs; [
    ripgrep
    fd
    lua-language-server
    vscode-langservers-extracted
    stylua
  ];
  # This is for plugins that will load at startup without using packadd:
  startupPlugins = with neovimPlugins; [
    oil-vcs-status
  ];
  startupPluginsVim = with vimPlugins; [
    lze
    lzextras
    plenary-nvim
    promise-async
    oil-nvim
    nvim-web-devicons
    tokyonight-nvim
    transparent-nvim
    lualine-nvim
    which-key-nvim
  ];
  # This is for plugins that will be loaded with packadd and autocmd
  lazyPlugins = with neovimPlugins; [
    harpoon
  ];
  lazyPluginsVim = with vimPlugins; [
    nvim-osc52
    neoscroll-nvim
    nvim-lspconfig
    nvim-treesitter-textobjects
    nvim-treesitter-endwise
    (nvim-treesitter.withPlugins (
      plugins: with plugins; [
        nix
        lua
      ]
    ))
    vim-startuptime
    nvim-notify
    noice-nvim
    todo-comments-nvim
    mini-indentscope
    nvim-highlight-colors
    smart-splits-nvim
    nvim-ts-autotag
    mini-pairs
    mini-ai
    mini-surround
    mini-move
    nvim-surround
    comment-nvim
    blink-cmp
    lazydev-nvim
    neoconf-nvim
    hover-nvim
    fidget-nvim
    telescope-nvim
    telescope-zf-native-nvim
    telescope-fzf-native-nvim
    hop-nvim
    conform-nvim
    tabout-nvim
    nvim-ufo
    luasnip
    grug-far-nvim
  ];
  # shared libraries to be added to LD_LIBRARY_PATH
  sharedLibraries = {};
  # env variables that should be available at run time for plugins
  environmentVariables = {
  };
  extraWrapperArgs = [];
in
{
  lspsAndRuntimeDeps = runtime;
  startupPlugins = startupPlugins ++ startupPluginsVim;
  optionalPlugins = lazyPlugins ++ lazyPluginsVim;
  inherit sharedLibraries environmentVariables extraWrapperArgs;
}
