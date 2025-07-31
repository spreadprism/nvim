{
  pkgs,
  vim_pkgs,
  nvim_pkgs,
  ...
}: {
  lspsAndRuntimeDeps = with pkgs; [
    curl
    grpcurl
    jq
    libxml2
  ];
  optionalPlugins = with vim_pkgs;
    [
      (nvim-treesitter.withPlugins (
        plugins:
          with plugins; [
            http
            html
            javascript
            typescript
          ]
      ))
    ]
    ++ (with nvim_pkgs; [
      kulala
    ]);
}
