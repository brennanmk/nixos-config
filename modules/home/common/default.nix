{ inputs, username, host, ... }: {
  imports = [
    ./git.nix
    ./gtk.nix           # gtk theme
    ./mako.nix          # notifications
    ./kitty.nix         # terminal
    ./packages.nix      # other packages
    ./scripts/scripts.nix # personal scripts
    ./syncthing.nix      # file sync
    ./xdg.nix           # xdg mime associations
    ./wofi.nix          # app launcher
  ];
}
