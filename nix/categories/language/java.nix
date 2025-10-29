{
  pkgs,
  vim_pkgs,
  nvim_pkgs,
  ...
}: {
  lspsAndRuntimeDeps = with pkgs; [
    jdt-language-server
    java-debug
    zulu17
  ];
  optionalPlugins = with vim_pkgs;
    [
      (nvim-treesitter.withPlugins (
        plugins:
          with plugins; [
            java
            xml
            groovy
          ]
      ))
    ]
    ++ (with nvim_pkgs; [
      jdtls
    ]);
}
