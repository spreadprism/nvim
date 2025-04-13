{pkgs, ...}: {
  optionalPlugins = with pkgs.vimPlugins; [
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
