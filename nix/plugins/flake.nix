{
  description = "Neovim plugins";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    "oil-vcs-status" = {
      url = "github:SirZenith/oil-vcs-status";
      flake = false;
    };
  };
  outputs = {nixpkgs} @ inputs:
    nixpkgs.lib.mapAttrs'
    (name: _input: {
      name = "plugins-${name}";
      value = inputs.${name};
    })
    (nixpkgs.lib.filterAttrs (n: _: n != "nixpkgs") inputs);
}
