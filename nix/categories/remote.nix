{ pkgs, ...}:
let
  vimPlugins = pkgs.vimPlugins;
in
{
  optionalPlugins = with vimPlugins; [
    nvim-osc52
  ];
}
