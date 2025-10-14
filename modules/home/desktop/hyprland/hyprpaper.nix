{ pkgs, ... }:

{
  home.packages = [ pkgs.hyprpaper ];

  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [
        "~/Pictures/wallpapers/wallpaper.jpg"
      ];

      wallpaper = [
        "DP-2,~/Pictures/wallpapers/wallpaper.jpg"
      ];
      
      ipc = true;
    };
  };
}
