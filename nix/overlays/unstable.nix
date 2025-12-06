{inputs}: final: _prev: {
  unstable = import inputs.nixpkgs-unstable {
    system = final.system;
    config.allowUnfree = final.config.allowUnfree;
  };
}
