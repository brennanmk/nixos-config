{ inputs, username, host, ... }: {
  imports = [
    ./git.nix
    ./gtk.nix           # gtk theme
    ./kitty.nix         # terminal
    ./packages.nix      # other packages
    ./scripts/scripts.nix # personal scripts
    ./xdg.nix           # xdg mime associations
  ];
}
