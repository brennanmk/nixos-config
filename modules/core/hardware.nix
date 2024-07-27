{ pkgs, ... }:
{  
  hardware.graphics.enable = true;
  hardware.enableRedistributableFirmware = true;
  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver
    vaapiIntel
    vaapiVdpau
    libvdpau-va-gl
    nvidia-vaapi-driver
  ];
}
