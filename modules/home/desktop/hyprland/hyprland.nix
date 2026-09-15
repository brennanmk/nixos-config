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
    configType = "hyprlang"; # keep hyprlang syntax; new default is "lua" as of stateVersion 26.05
    xwayland = {
      enable = true;
      # hidpi = true;
    };
    systemd.enable = false;  # Disabled when using UWSM
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
  };
}
