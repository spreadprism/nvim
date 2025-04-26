{
  pkgs,
  vim_pkgs,
  ...
}: {
  lspsAndRuntimeDeps = with pkgs; [
    gopls
    delve
    golangci-lint
    gofumpt
  ];
  optionalPlugins = with vim_pkgs; [
    nvim-dap-go
    neotest-golang
    (nvim-treesitter.withPlugins (
      plugins:
        with plugins; [
          go
          gowork
          gomod
          gosum
          gotmpl
        ]
    ))
  ];
}
