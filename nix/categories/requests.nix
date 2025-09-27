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
  optionalPlugins = with vim_pkgs; let
    kulala-ts-http = pkgs.tree-sitter.buildGrammar {
      language = "kulala_http";
      version = nvim_pkgs.kulala.version; # <-- this can be anything I ususally do like, inputs.kulala-grammar.shortRev
      src = nvim_pkgs.kulala;
      location = "lua/tree-sitter";
    };
  in
    [
      (nvim-treesitter.withPlugins (
        plugins:
          with plugins; [
            http
            html
            javascript
            typescript
            kulala-ts-http
          ]
      ))
    ]
    ++ (with nvim_pkgs; [
      kulala
    ]);
}
