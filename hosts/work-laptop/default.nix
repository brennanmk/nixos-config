{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./nvidia.nix
    ./../../modules/core
  ];

  hardware.enableAllFirmware = true;
  hardware.nvidia-container-toolkit.enable = true;
  services.blueman.enable = true;

  environment.systemPackages = with pkgs; [
    acpi
    brightnessctl
    powertop
    libinput
    libinput-gestures
    intel-gpu-tools   # intel_gpu_top, replaces the amdgpu tooling
  ];

  services = {
    # Intel DPTF thermal/power policy — the reason this host does not need
    # cpupower/acpi_call the way hosts/laptop does.
    thermald.enable = true;

    upower = {
      enable = true;
      percentageLow = 20;
      percentageCritical = 5;
      percentageAction = 3;
      criticalPowerAction = "PowerOff";
    };

    # Core Ultra 9 runs intel_pstate, which only exposes powersave/performance;
    # the governor split plus EPP hints is what actually controls the P/E-core
    # boost behaviour here.
    auto-cpufreq = {
      enable = true;
      settings = {
        battery = {
          governor = "powersave";
          energy_performance_preference = "balance_power";
          turbo = "auto";
        };
        charger = {
          governor = "performance";
          energy_performance_preference = "performance";
          turbo = "auto";
        };
      };
    };
  };

  system.nixos.tags = [ "default" ];
}
