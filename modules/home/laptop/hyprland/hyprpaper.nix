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
        ",~/Pictures/wallpapers/wallpaper.jpg"
      ];
      
      ipc = true;
    };
  };
}
