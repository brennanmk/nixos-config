{ username, pkgs, ... }:
{
  services = {
    # Existing services
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

    zerotierone = {
      enable = true;
      joinNetworks = [
        "a84ac5c10ad39a1c"
      ];
    };

    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    ollama = {
      enable = true;
      acceleration = "cuda";
    };
  };

}

