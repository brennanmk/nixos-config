{ inputs, pkgs, ...}: 
{
  home.packages = with pkgs; [
    # swww
    swaybg
    inputs.hypr-contrib.packages.${pkgs.system}.grimblast
    hyprpicker
    grim
    slurp
    wl-clipboard
    wl-clip-persist
    wf-recorder
    glib
    wayland
    xdg-utils
  ];

  systemd.user.targets.hyprland-session.Unit.Wants = [ "xdg-desktop-autostart.target" ];
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland = {
      enable = true;
      # hidpi = true;
    };
    systemd.enable = true;
  };
}
