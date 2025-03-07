{ username, ... }:
{
  services = {
    logind.lidSwitch = "ignore";
    gvfs.enable = true;
    gnome.gnome-keyring.enable = false;
    dbus.enable = true;
    fstrim.enable = true;
    printing.enable = true;
    displayManager.autoLogin = {
      enable = true;
      user = "${username}";
    };
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

}
