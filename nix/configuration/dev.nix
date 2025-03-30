{ nixpkgs, ...}:
{
  settings = {
    wrapRc = true;
    aliases = [];
  };
  categories = {
    tmux = true;
    ai = true;
    git = true;
    debugging = true;
    testing = true;
    # langs
    go = true;
  };
}
