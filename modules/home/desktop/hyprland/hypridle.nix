{ pkgs, ... }:
{

  home.packages = [ pkgs.hypridle pkgs.wlopm ];

  services.hypridle = {
      enable = true;
      settings = {
        general = {
          after_sleep_cmd = "sleep 1 && wlopm --on '*'";
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
            on-timeout = "wlopm --off DP-1; wlopm --off DP-2";
            on-resume = "sleep 1 && wlopm --on DP-1; wlopm --on DP-2";
          }
        ];
      };
  };
}
