{ inputs, username, host, ...}: {
  imports = [
    ./hyprland
    ./waybar
    ./packages.nix
    ./zsh.nix
  ];
}
