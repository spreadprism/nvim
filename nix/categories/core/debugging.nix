{vim_pkgs, ...}: {
  startupPlugins = with vim_pkgs; [
    nvim-nio
  ];
  optionalPlugins = with vim_pkgs; [
    nvim-dap
    nvim-dap-ui
    nvim-dap-virtual-text
  ];
}
