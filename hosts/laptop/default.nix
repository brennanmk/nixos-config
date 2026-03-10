{ pkgs, config, lib, ... }: 
{
  imports = [
    ./hardware-configuration.nix
    ./nvidia.nix
    ./../../modules/core
  ];

  hardware.enableAllFirmware  = true;
  environment.systemPackages = with pkgs; [
    acpi
    brightnessctl
    cpupower-gui
    powertop
    libinput
    libinput-gestures
  ];
  
  services = {    
    thermald.enable = true;

    upower = {
      enable = true;
      percentageLow = 20;
      percentageCritical = 5;
      percentageAction = 3;
      criticalPowerAction = "PowerOff";
    };

    auto-cpufreq = {
      enable = true;
      settings = {
        battery = {
          governor = "performance";
          turbo = "auto";
        };
        charger = {
          governor = "performance";
          turbo = "auto";
        };
      };
    };
  };

  specialisation = {
    rt-kernel.configuration = {
      system.nixos.tags = [ "rt-kernel" ];
      boot.kernelPackages = lib.mkForce pkgs.linuxPackages-rt_latest;
    };
  };

  boot = {
    kernelModules = ["acpi_call"];
    extraModulePackages = with config.boot.kernelPackages;
      [
        acpi_call
        cpupower
      ]
      ++ [pkgs.cpupower-gui];
  };
}
