final: prev: {
  codelldb = prev.vscode-extensions.vadimcn.vscode-lldb.overrideAttrs (_: {
    postPatch = let
      # grab the bin at .share/vscode/extensions/vadimcn.vscode-lldb/adapter
    in ''
      mkdir -p $out/bin
      cp -r ${prev.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb $out/bin
    '';
  });
}
