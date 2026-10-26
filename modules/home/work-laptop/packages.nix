{ inputs, pkgs, ... }:
{
  home.packages = (with pkgs; [
    saleae-logic-2

    # MCUXpresso SDK builds. The extension's own MCUXpresso Installer is a
    # .deb run via pkexec, which can't work on NixOS, so supply the
    # toolchain here and point the extension at it instead (west comes from
    # the shared python3 env in modules/home/common).
    gcc-arm-embedded
    ninja
    segger-jlink # J-Link probe tools (JLinkExe, JLinkGDBServer); udev rules in hosts/work-laptop
    mcuxpressoide # pkgs/mcuxpressoide.nix; installer must be in the store first (see its requireFile message)
  ]);
}
