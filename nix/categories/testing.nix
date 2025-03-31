{pkgs, ...}: let
  neovimPlugins = pkgs.neovimPlugins;
  vimPlugins = pkgs.vimPlugins;
in {
  startupPlugins = with vimPlugins; [
    nvim-nio
  ];
  optionalPlugins = with vimPlugins;
    [
      neotest
    ]
    ++ (with neovimPlugins; [
      ]);
}
