{pkgs, ...}: let
  neovimPlugins = pkgs.neovimPlugins;
  vimPlugins = pkgs.vimPlugins;
in {
  startupPlugins = with vimPlugins; [
    nvim-nio
  ];
  optionalPlugins = with vimPlugins;
    [
      nvim-dap
      nvim-dap-ui
      nvim-dap-virtual-text
    ]
    ++ (with neovimPlugins; [
      ]);
}
