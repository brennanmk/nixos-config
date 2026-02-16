{ inputs, pkgs, ... }:
{
  home.packages = (with pkgs; [
    steam
    gamescope
    prismlauncher
  ]) ++ [
    inputs.hytale-launcher.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
