{vim_pkgs, ...}: {
  optionalPlugins = with vim_pkgs; [
    nvim-treesitter-textobjects
    nvim-treesitter-endwise
    (nvim-treesitter.withPlugins (
      plugins:
        with plugins; [
          nix
          lua
          luadoc
          bash
          make
          json
          toml
          yaml
          markdown
          markdown_inline
          regex
          vim
          vimdoc
          proto
        ]
    ))
  ];
}
