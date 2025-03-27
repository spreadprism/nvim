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
  ];
  # This is for plugins that will load at startup without using packadd:
  startupPlugins = with neovimPlugins; [];
  startupPluginsVim = with vimPlugins; [
    lze
    lzextras
    oil-nvim
    nvim-web-devicons
    tokyonight-nvim
    transparent-nvim
    lualine-nvim
  ];
  # This is for plugins that will be loaded with packadd and autocmd
  lazyPlugins = with neovimPlugins; [
  ];
  lazyPluginsVim = with vimPlugins; [
    nvim-osc52
    neoscroll-nvim
    nvim-treesitter-textobjects
    (nvim-treesitter.withPlugins (
      plugins: with plugins; [
        nix
        lua
      ]
    ))
    vim-startuptime
    nvim-notify
    noice-nvim
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
