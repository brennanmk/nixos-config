{ pkgs, ... }:
{  
  hardware.enableRedistributableFirmware = true;
  hardware.openrazer.enable = true;
  environment.systemPackages = with pkgs; [
      openrazer-daemon
   ];
}
