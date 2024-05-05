{ pkgs, username, ... }: 
{
  services.xserver = {
    enable = true;
    xkb.layout = "us";
    displayManager = {
      gdm.enable = true;
      defaultSession = "none+i3";
    };

    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
      extraPackages = with pkgs; [
        dmenu
        i3status
        rofi
        i3blocks
     ];
    };

    libinput = {
      enable = true;
    };
  };
  # To prevent getting stuck at shutdown
  systemd.extraConfig = "DefaultTimeoutStopSec=10s";
}
