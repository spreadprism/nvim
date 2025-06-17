final: prev: {
  helm-ls = prev.helm-ls.overrideAttrs (old: rec {
    version = "0.4.1";
    src = prev.fetchFromGitHub {
      owner = "mrjosh";
      repo = "helm-ls";
      rev = "v${version}";
      hash = "sha256-z+gSD7kcDxgJPoYQ7HjokJONjgAAuIIkg1VGyV3v01k=";
    };
  });
}
