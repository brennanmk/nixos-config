{ inputs, username, host, ... }: {
  imports = [
    ./git.nix
    ./gtk.nix           # gtk theme
    ./mako.nix          # notifications
    ./kitty.nix         # terminal
    ./packages.nix      # other packages
    ./scripts/scripts.nix # personal scripts
  ];
}
