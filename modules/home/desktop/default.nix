{ inputs, username, host, ...}: {
  imports = [
    ./hyprland
    ./packages.nix
    ./zsh.nix
  ];
}
