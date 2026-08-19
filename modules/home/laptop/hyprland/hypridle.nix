{ pkgs, ... }:
{

  home.packages = [ pkgs.hypridle ];

  services.hypridle = {
      enable = true;
      settings = {
        general = {
          after_sleep_cmd = "hyprctl dispatch dpms on";
          ignore_dbus_inhibit = false;
          lock_cmd = "echo '' | socat - UNIX-CONNECT:/tmp/quickshell_lockScreen";
        };

        listener = [
          {
            timeout = 900;
            on-timeout = "echo '' | socat - UNIX-CONNECT:/tmp/quickshell_lockScreen";
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
