{ config, lib, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./nvidia.nix
    ./../../modules/core
  ];
  powerManagement.cpuFreqGovernor = "performance";
}
