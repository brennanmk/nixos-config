{ inputs, pkgs, ...}: 
{
  home.packages = with pkgs; [
    swaybg
    hyprshot
    wl-clipboard
    wl-clip-persist
    wf-recorder
    glib
    wayland
    xdg-utils
    xdg-desktop-portal-gtk
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland = {
      enable = true;
      # hidpi = true;
    };
    systemd.enable = false;  # Disabled when using UWSM
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
  };
}
