final: prev: {
  codelldb = prev.vscode-extensions.vadimcn.vscode-lldb.overrideAttrs (_: {
    postPatch = ''
      mkdir -p $out/bin
      cp -r ${prev.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb $out/bin
    '';
  });

  # Metadata for this overlay
  overlayMeta =
    (prev.overlayMeta or {})
    // {
      codelldb = {
        type = "debug-adapter";
        sourcePackage = "vscode-extensions.vadimcn.vscode-lldb";
        languages = ["rust" "c" "cpp"];
      };
    };
}
