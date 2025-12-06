final: prev: {
  codelldb = prev.vscode-extensions.vadimcn.vscode-lldb.overrideAttrs (_: {
    postPatch = ''
      mkdir -p $out/bin
      cp -r ${prev.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb $out/bin
    '';
  });
}
