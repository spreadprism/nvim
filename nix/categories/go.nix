{ pkgs, ...}:
let
  neovimPlugins = pkgs.neovimPlugins;
  vimPlugins = pkgs.vimPlugins;
in
{
  lspsAndRuntimeDeps = with pkgs; [
    gopls
    delve
    golangci-lint
  ];
  optionalPlugins = with vimPlugins; [
    nvim-dap-go
    neotest-golang
    (nvim-treesitter.withPlugins (
      plugins: with plugins; [
        go
      ]
    ))

  ] ++ ( with neovimPlugins; [
  ]);
}
