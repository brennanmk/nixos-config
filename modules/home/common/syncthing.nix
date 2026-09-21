{ ... }:
{
  # Runs as a systemd --user service; web GUI at localhost:8384. Firewall is
  # disabled machine-wide (modules/core/network.nix) so no extra ports needed
  # for LAN discovery/transfer.
  services.syncthing = {
    enable = true;
    tray.enable = true;
  };
}
