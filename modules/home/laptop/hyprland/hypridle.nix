{ pkgs, ... }:
{

  home.packages = [ pkgs.hypridle ];

  services.hypridle = {
      enable = true;
      settings = {
        general = {
          before_sleep_cmd = "pidof hyprlock || hyprlock";
          after_sleep_cmd = "hyprctl dispatch dpms on";
          ignore_dbus_inhibit = false;
          lock_cmd = "hyprlock";
        };

        listener = [
          {
            timeout = 900;
            on-timeout = "hyprlock";
          }
          {
            timeout = 1000;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
  };
}
