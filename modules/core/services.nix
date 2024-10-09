{ ... }: 
{
  services = {
    logind.lidSwitch = "ignore";
    gvfs.enable = true;
    gnome.gnome-keyring.enable = true;
    dbus.enable = true;
    fstrim.enable = true;
  };
}
