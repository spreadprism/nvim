final: prev: {
  commit-lsp = prev.rustPlatform.buildRustPackage rec {
    pname = "commit-lsp";
    version = "0.2.0";

    src = prev.fetchFromGitHub {
      owner = "texel-sensei";
      repo = "commit-lsp";
      rev = "v${version}";
      hash = "sha256-N+KKIGvza5pTaUkn2zYHSB7pvzhkXricwvG/8jZ/TGE=";
    };

    cargoHash = "sha256-u2Ts1az7+31jv8jKsSKmhxyhu5adLIe3WUjTzgZTMh0=";

    nativeBuildInputs = with prev; [
      pkg-config
    ];

    buildInputs = with prev; [
      openssl
    ];

    meta = with prev.lib; {
      description = "Language Server for commit messages";
      homepage = "https://github.com/texel-sensei/commit-lsp";
      license = licenses.gpl3Only;
      maintainers = [];
      mainProgram = "commit-lsp";
    };
  };
}
