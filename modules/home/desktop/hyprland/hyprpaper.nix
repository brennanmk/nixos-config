{ pkgs, ... }:

{
  home.packages = [ pkgs.hyprpaper ];

  services.hyprpaper.enable = true;

  xdg.configFile."hypr/hyprpaper.conf" = {
    force = true;
    text = ''
      splash = false
      preload = ~/Pictures/wallpapers/wallpaper.jpg
      ipc = true

      wallpaper {
        monitor =
        path = ~/Pictures/wallpapers/wallpaper.jpg
      }
    '';
  };
}
