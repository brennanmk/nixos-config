{ inputs, pkgs, ... }:
{
  home.packages = (with pkgs; [
    prismlauncher
  ]) ++ [
    inputs.hytale-launcher.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
