{ inputs, pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
    ];
    config = {
      common = {
        default = ["hyprland" "gtk"];
      };
      hyprland = {
        default = ["hyprland" "gtk"];
        "org.freedesktop.impl.portal.Screenshot" = ["hyprland"];
        "org.freedesktop.impl.portal.ScreenCast" = ["hyprland"];
        "org.freedesktop.impl.portal.Screencast" = ["hyprland"];
      };
    };
  };
}
