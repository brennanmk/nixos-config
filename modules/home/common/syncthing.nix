{ ... }:
{
  # The syncthing daemon itself runs as a system service (modules/core/syncthing.nix);
  # only the tray lives here. Enabling the home-manager daemon too would start a
  # second instance fighting over the same config dir lock.
  services.syncthing.tray.enable = true;
}
