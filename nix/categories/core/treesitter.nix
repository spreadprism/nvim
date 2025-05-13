{
  vim_pkgs,
  nvim_pkgs,
  ...
}: {
  optionalPlugins = with vim_pkgs;
    [
      nvim-treesitter-textobjects
      nvim-treesitter-endwise
      (nvim-treesitter.withPlugins (
        plugins:
          with plugins; [
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
          ]
      ))
    ]
    ++ (with nvim_pkgs; [
      treesitter-context
    ]);
}
