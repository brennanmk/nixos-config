{ pkgs, username, ... }: 
{
  services.libinput.enable = true;
  services.displayManager.defaultSession = "xfce+i3";

  services.xserver = {
    enable = true;

    xkb.layout = "us";

    desktopManager = {
      xterm.enable = false;
      xfce = {
        enable = true;
        noDesktop = true;
        enableXfwm = false;
      };
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

    displayManager = {
      gdm.enable = true;
    };

  };
  # To prevent getting stuck at shutdown
  systemd.extraConfig = "DefaultTimeoutStopSec=10s";
}
