final: prev: {
  java-debug = prev.vscode-extensions.vscjava.vscode-java-debug.overrideAttrs (_: {
    postInstall = let
    in ''
      mkdir -p $out/share
      mkdir -p $out/bin

      # Copy the server directory
      cp ${prev.vscode-extensions.vscjava.vscode-java-debug}/share/vscode/extensions/vscjava.vscode-java-debug/server/*.jar $out/share/java-debug.jar

      # Create a wrapper script that outputs the path
      cat > $out/bin/java-debug-path <<EOF
      #!/bin/sh
      echo "$out/share/java-debug.jar"
      EOF

      chmod +x $out/bin/java-debug-path
    '';
  });
}
