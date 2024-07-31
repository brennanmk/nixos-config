{ pkgs, username, ... }: 
{
  services = {
    xserver = {
      enable = true;
      layout = "us";
    };

    displayManager.autoLogin = {
      enable = true;
      user = "${username}";
    };
  };
  # To prevent getting stuck at shutdown
  systemd.extraConfig = "DefaultTimeoutStopSec=10s";
}
