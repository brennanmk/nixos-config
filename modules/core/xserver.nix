{ pkgs, username, ... }:
{

  services.xserver = {
    enable = true;

    xkb.layout = "us";


  };
  # To prevent getting stuck at shutdown
  systemd.settings.Manager = {
    DefaultTimeoutStopSec = "10s";
  };
}
