{ pkgs, ... }: 
{
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    # firewall.enable = false;
  };

  environment.systemPackages = with pkgs; [
    networkmanagerapplet
  ];
}
