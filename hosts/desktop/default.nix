{ config, lib, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./nvidia.nix
    ./../../modules/core
    ./../../modules/core/gaming.nix
  ];
  powerManagement.cpuFreqGovernor = "performance";
}
