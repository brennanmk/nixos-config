{ config, lib, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./nvidia.nix
    ./../../modules/core
  ];
  hardware.enableAllFirmware  = true;
  powerManagement.cpuFreqGovernor = "performance";
}
