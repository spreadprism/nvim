{...}: {
  dotenv = {
    enable = true;
    filename = [".env" ".env.local"];
  };

  scripts.nvim_dev.exec = ''
    git add -A
    nix run .#nvim_dev "$@"
  '';
}
