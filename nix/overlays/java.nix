final: prev: {
  java-debug = prev.vscode-extensions.vscjava.vscode-java-debug.overrideAttrs (_: {
    postInstall = ''
      mkdir -p $out/share
      mkdir -p $out/bin

      # Copy the server directory
      cp ${prev.vscode-extensions.vscjava.vscode-java-debug}/share/vscode/extensions/vscjava.vscode-java-debug/server/*.jar $out/share/java-debug.jar
    '';
  });

  # Metadata for this overlay
  overlayMeta =
    (prev.overlayMeta or {})
    // {
      java-debug = {
        type = "debug-adapter";
        sourcePackage = "vscode-extensions.vscjava.vscode-java-debug";
        languages = ["java"];
        path = "${final.java-debug}/share/java-debug.jar";
      };
    };
}
