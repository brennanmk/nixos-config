{ username, ... }:
let
  # Device ID of the syncthing server behind https://syncthing.bmillerklugman.me
  # (Actions -> Show ID in its web UI).
  serverDeviceId = "W6FKA5U-6OXP4LY-Z2SQYXE-WFITTRH-5YGLGCC-SCHJ5IJ-ZQ2PWAA-CYH53A2";
in
{
  services.syncthing = {
    enable = true;
    user = "${username}";
    group = "users";
    dataDir = "/home/${username}";
    configDir = "/home/${username}/.config/syncthing";

    # Local web UI only: http://127.0.0.1:8384
    guiAddress = "127.0.0.1:8384";

    openDefaultPorts = true;

    # Declarative: anything added by hand in the GUI gets reverted on rebuild.
    overrideDevices = true;
    overrideFolders = true;

    settings = {
      devices = {
        "server" = {
          id = serverDeviceId;
          # Reachable over zerotier/LAN; falls back to discovery/relays.
          addresses = [ "dynamic" ];
        };
      };

      folders = {
        "org" = {
          # Folder ID must match the folder ID on the server.
          id = "org";
          path = "/home/${username}/org";
          devices = [ "server" ];
          type = "sendreceive";
          # Emacs lock/autosave droppings shouldn't sync.
          ignorePatterns = [
            "#*#"
            ".#*"
            "*~"
            ".org-id-locations"
            "*.org_archive~"
          ];
          versioning = {
            type = "simple";
            params.keep = "10";
          };
        };
      };

      options = {
        urAccepted = -1;
        relaysEnabled = true;
      };
    };
  };
}
