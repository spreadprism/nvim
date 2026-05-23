final: prev: {
  copilot-language-server = prev.copilot-language-server;

  # Metadata for this overlay
  overlayMeta =
    (prev.overlayMeta or {})
    // {
      copilot-language-server = {
        path = "${final.copilot-language-server}/bin/copilot-language-server";
      };
    };
}
