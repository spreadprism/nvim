{ pkgs, ...}:
let
  neovimPlugins = pkgs.neovimPlugins;
  vimPlugins = pkgs.vimPlugins;
in
{
  optionalPlugins = with vimPlugins; [
    codecompanion-nvim
  ] ++ ( with neovimPlugins; [
    copilot
  ]);
}
