{ inputs, username, host, ...}: {
  imports = [
    ./hyprland
    ./waybar
    ./packages.nix
    ./zsh.nix
    ./swaync/swaync.nix
  ];
}
