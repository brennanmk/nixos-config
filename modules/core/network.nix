{ pkgs, ... }: 
{
  networking = {
    hostName = "nixos";
    networkmanager = {
      enable = true;
      plugins = with pkgs; [ networkmanager-openconnect ];

      # Credentials live outside the store: EDUROAM_IDENTITY=... and EDUROAM_PASSWORD=... in this file
      ensureProfiles = {
        environmentFiles = [ "/etc/nixos-secrets/eduroam.env" ];
        profiles.eduroam = {
          connection = {
            id = "eduroam";
            type = "wifi";
          };
          wifi = {
            mode = "infrastructure";
            ssid = "eduroam";
          };
          wifi-security.key-mgmt = "wpa-eap";
          "802-1x" = {
            eap = "peap";
            phase2-auth = "mschapv2";
            identity = "$EDUROAM_IDENTITY";
            password = "$EDUROAM_PASSWORD";
            # system-ca-certs doesn't work on NixOS (no hashed cert dir), so point at the bundle
            ca-cert = "/etc/ssl/certs/ca-bundle.crt";
            domain-suffix-match = "radius.whoi.edu";
          };
          ipv4.method = "auto";
          ipv6.method = "auto";
        };
      };
    };
    firewall.enable = false;
  };

  # Make sure the secrets file exists so the ensure-profiles service doesn't fail on hosts without it
  systemd.tmpfiles.rules = [
    "d /etc/nixos-secrets 0700 root root -"
    "f /etc/nixos-secrets/eduroam.env 0600 root root -"
  ];

  environment.systemPackages = with pkgs; [
    networkmanagerapplet
    openconnect
  ];
}
