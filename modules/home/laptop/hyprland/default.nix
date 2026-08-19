{ inputs, ... }:
{
  imports = [
    ./hyprland.nix
    ./hypridle.nix
    ./config.nix
    ./userprefs.nix
    ./variables.nix
    ../../common/quickshell
    ../../common/hypr-scripts
    ../../common/hypr-animations.nix
  ];
}
