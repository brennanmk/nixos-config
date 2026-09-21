{ username, pkgs, ... }:
{
  services = {
    # System services
    gvfs.enable = true;
    dbus.enable = true;
    fstrim.enable = true;
    printing.enable = true;
    ratbagd.enable = true;

    # Network Discovery & VPN
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

    # AI / LLM
    ollama = {
      enable = true;
      package = pkgs.ollama-bin;
    };

    # Display Manager & Auto-Login
    displayManager = {
      defaultSession = "hyprland-uwsm";

      sddm = {
        enable = true;
        wayland.enable = true;
      };

      autoLogin = {
        enable = true;
        user = "${username}";
      };
    };
  };
}
