{ pkgs, ... }:
{
  hardware.enableRedistributableFirmware = true;

 hardware.bluetooth.enable = true; # enables support for Bluetooth
 hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

 hardware.xone.enable = true;

  # No swapDevices on any host, so memory pressure went straight to the OOM
  # killer with nothing cushioning it. zram gives it compressed RAM to
  # reclaim into first, and the gentler pressure keeps the rest of the
  # system (including the compositor cleaning up a killed client's GPU
  # buffers) from getting caught mid-OOM.
  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };
}
